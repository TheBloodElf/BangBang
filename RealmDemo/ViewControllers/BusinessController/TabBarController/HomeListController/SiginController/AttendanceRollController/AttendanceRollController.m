//
//  AttendanceRollController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/21.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "AttendanceRollController.h"
#import "CreateAttendanceController.h"
#import "UpdateAttendanceController.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "AttendanceRollCell.h"
#import "NoResultView.h"

@interface AttendanceRollController ()<UITableViewDelegate,UITableViewDataSource,AttendanceRollCellDelegate,RBQFetchedResultsControllerDelegate>
{
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_siginRuleFetchedResultsController;//签到规则数据监听
    UITableView *_tableView;//展示数据的表格视图
    NSMutableArray<SiginRuleSet*> *_dataArr;//当前公司签到规则数组
    NoResultView *_noResultView;
}
@end

@implementation AttendanceRollController

#pragma mark -- 
#pragma mark -- LifeStyle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"公司考勤点";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    _siginRuleFetchedResultsController = [_userManager createSiginRuleFetchedResultsController];
    _siginRuleFetchedResultsController.delegate = self;
    _dataArr = [_userManager getSiginRule:_userManager.user.currCompany.company_no];
    //设计图上面有一条灰色的线 15高
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 15)];
    topView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:topView];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 15, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 15) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _noResultView = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 15)];
    if(_dataArr.count == 0) {
        _tableView.tableFooterView = _noResultView;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightNavigationBarAction:)];
    } else {
        _tableView.tableFooterView = [UIView new];
        self.navigationItem.rightBarButtonItem = nil;
    }
    [_tableView registerNib:[UINib nibWithNibName:@"AttendanceRollCell" bundle:nil] forCellReuseIdentifier:@"AttendanceRollCell"];
    [self.view addSubview:_tableView];
    //进来就获取一次签到规则
    [self getCompanySiginRule];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    _dataArr = [_userManager getSiginRule:_userManager.user.currCompany.company_no];
    [_tableView reloadData];
    if(_dataArr.count == 0) {
        _tableView.tableFooterView = _noResultView;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightNavigationBarAction:)];
    } else {
        _tableView.tableFooterView = [UIView new];
        self.navigationItem.rightBarButtonItem = nil;
    }
}
#pragma mark --
#pragma mark -- 这里是需要有网就操作的
//获取签到规则
- (void)getCompanySiginRule {
    [UserHttp getSiginRule:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *dic in data) {
            NSMutableDictionary *dicDic = [dic mutableCopy];
            dicDic[@"work_day"] = [dicDic[@"work_day"] componentsJoinedByString:@","];
            SiginRuleSet *set = [SiginRuleSet new];
            [set mj_setKeyValues:dicDic];
            //这里动态添加签到地址
            RLMArray<PunchCardAddressSetting> *settingArr = [[RLMArray<PunchCardAddressSetting> alloc] initWithObjectClassName:@"PunchCardAddressSetting"];
            for (NSDictionary *settingDic in dicDic[@"address_settings"]) {
                PunchCardAddressSetting *setting = [PunchCardAddressSetting new];
                [setting mj_setKeyValues:settingDic];
                [settingArr addObject:setting];
            }
            set.json_list_address_settings = settingArr;
            [array addObject:set];
        }
        [_userManager updateSiginRule:array companyNo:_userManager.user.currCompany.company_no];
    }];
}
#pragma mark -- 
#pragma mark -- AttendanceRollCellDelegate
- (void)attendanceRollDel:(SiginRuleSet *)set {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"你确定要删除该办签到规则？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //办公地点 地址删除按钮被点击
        [UserHttp deleteSiginRule:set.setting_guid handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            [_userManager deleteSiginRule:set];
        }];
    }];
    [alert addAction:ok];
    [alert addAction:cancle];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AttendanceRollCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttendanceRollCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.data = _dataArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UpdateAttendanceController *update = [UpdateAttendanceController new];
    update.data = _dataArr[indexPath.row];
    [self.navigationController pushViewController:update animated:YES];
}

#pragma mark --
#pragma mark -- ConfigNavigationBar
- (void)rightNavigationBarAction:(UIButton*)item {
    CreateAttendanceController *vc = [CreateAttendanceController new];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
