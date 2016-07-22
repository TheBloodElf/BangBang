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
#import "NoSiginruleView.h"

@interface AttendanceRollController ()<UITableViewDelegate,UITableViewDataSource,AttendanceRollCellDelegate,RBQFetchedResultsControllerDelegate>
{
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_siginRuleFetchedResultsController;//签到规则数据监听
    UITableView *_tableView;//展示数据的表格视图
    NSMutableArray<SiginRuleSet*> *_dataArr;//当前公司签到规则数组
    NoSiginruleView *_noSiginruleView;
}
@end

@implementation AttendanceRollController

#pragma mark -- 
#pragma mark -- LifeStyle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"公司签到点";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    _siginRuleFetchedResultsController = [_userManager createSiginRuleFetchedResultsController:_userManager.user.currCompany.company_no];
    _siginRuleFetchedResultsController.delegate = self;
    _dataArr = [_userManager getSiginRule:_userManager.user.currCompany.company_no];
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _noSiginruleView = [[NoSiginruleView alloc] initWithFrame:_tableView.bounds];
    if(_dataArr.count == 0) {
        _tableView.tableFooterView = _noSiginruleView;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightNavigationBarAction:)];
        //从服务器获取一次规则
        [UserHttp getSiginRule:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSMutableArray *array = [@[] mutableCopy];
            for (NSDictionary *dic in data) {
                SiginRuleSet *set = [[SiginRuleSet alloc] initWithJsonDic:dic];
                [array addObject:set];
            }
            [_userManager updateSiginRule:array companyNo:_userManager.user.currCompany.company_no];
        }];
    }
    else {
        _tableView.tableFooterView = [UIView new];
        self.navigationItem.rightBarButtonItem = nil;
    }
    [_tableView registerNib:[UINib nibWithNibName:@"AttendanceRollCell" bundle:nil] forCellReuseIdentifier:@"AttendanceRollCell"];
    [self.view addSubview:_tableView];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:nil];
    [self.navigationController.navigationBar setShadowImage:nil];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    _dataArr = (id)controller.fetchedObjects;
    [_tableView reloadData];
    if(_dataArr.count == 0) {
        _tableView.tableFooterView = _noSiginruleView;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightNavigationBarAction:)];
    }
    else {
        _tableView.tableFooterView = [UIView new];
        self.navigationItem.rightBarButtonItem = nil;
    }
}
#pragma mark -- 
#pragma mark -- AttendanceRollCellDelegate
- (void)attendanceRollDel:(SiginRuleSet *)set {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"你确定要删除该办签到规则？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //办公地点 地址删除按钮被点击
        [self.navigationController.view showLoadingTips:@""];
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
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 15.f;
}
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
