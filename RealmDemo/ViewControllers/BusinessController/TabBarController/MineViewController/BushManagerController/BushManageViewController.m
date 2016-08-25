//
//  BushManageViewController.m
//  BangBang
//
//  Created by Kiwaro on 14-12-16.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import "BushManageViewController.h"
#import "BushManagerCell.h"
#import "BushSearchViewController.h"
#import "Company.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "BushDetailController.h"
#import "CreateBushController.h"
#import "RequestManagerController.h"
#import "MoreSelectView.h"

#import "NoResultView.h"

@interface BushManageViewController ()<UITableViewDataSource,UITableViewDelegate,RBQFetchedResultsControllerDelegate,MoreSelectViewDelegate> {
    UserManager *_userManager;//用户管理器
    UITableView *_tableView;//展示数据的表格视图
    NSMutableArray<Company*> *_companyArr;//圈子数组
    RBQFetchedResultsController *_companyFetchedResultsController;//圈子数据监听
    NoResultView *_noDataView;//没有数据显示的视图
    MoreSelectView *_moreSelectView;//多选视图
}
@property (nonatomic, strong) UIButton *backButton;
@end

@implementation BushManageViewController
#pragma mark --
#pragma mark -- ControllerLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"圈子管理";
    _companyArr = [@[] mutableCopy];
    _userManager = [UserManager manager];
    _companyFetchedResultsController = [_userManager createCompanyFetchedResultsController];
    _companyFetchedResultsController.delegate = self;
    //设置标签的位置和约束
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"BushManagerCell" bundle:nil] forCellReuseIdentifier:@"BushManagerCell"];
    [self.view addSubview:_tableView];
    WeakSelf(weakSelf)
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [UserHttp getCompanysUserGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
            [_tableView.mj_header endRefreshing];
            if(error) {
                [weakSelf.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSMutableArray<Company*> *companys = [@[] mutableCopy];
            for (NSDictionary *dic in data) {
                Company *company = [[Company alloc] initWithJSONDictionary:dic];
                [companys addObject:company];
            }
            [_userManager updateCompanyArr:companys];
        }];
    }];
    //创建空太图
    _noDataView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    //只显示自己状态为4或者1的
    for (Company *company in [_userManager getCompanyArr]) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
        if(employee.status == 1 || employee.status == 4) {
            [_companyArr addObject:company];
        }
    }
    if(_companyArr.count == 0)
        _tableView.tableFooterView = _noDataView;
    [_tableView reloadData];
    //创建多选视图
    //是不是当前圈子的管理员
    if([_userManager.user.currCompany.admin_user_guid isEqualToString:_userManager.user.user_guid]) {
        _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100, 0, 100, 120)];
        _moreSelectView.selectArr = @[@"加入圈子",@"创建圈子",@"申请管理"];
    }
    else {
        _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100, 0, 100, 80)];
        _moreSelectView.selectArr = @[@"加入圈子",@"创建圈子"];
    }
    _moreSelectView.delegate = self;
    [_moreSelectView setupUI];
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
    //创建右边导航按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked:)];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)rightBarButtonClicked:(UIBarButtonItem*)item {
    if(_moreSelectView.isHide)
        [_moreSelectView showSelectView];
    else
        [_moreSelectView hideSelectView];
}
#pragma mark -- 
#pragma mark -- MoreSelectViewDelegate
-(void)moreSelectIndex:(int)index {
    if(index == 0) {//加入圈子
        BushSearchViewController *search = [BushSearchViewController new];
        [self.navigationController pushViewController:search animated:YES];
    } else if (index == 1) {//创建圈子
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
        CreateBushController *bush = [story instantiateViewControllerWithIdentifier:@"CreateBushController"];
        [self.navigationController pushViewController:bush animated:YES];
    } else {//申请管理
        RequestManagerController *manager = [RequestManagerController new];
        [self.navigationController pushViewController:manager animated:YES];
    }
}
#pragma mark -- 
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [_companyArr removeAllObjects];
    //只显示自己状态为4或者1的
    for (Company *company in (id)controller.fetchedObjects) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
        if(employee.status == 1 || employee.status == 4) {
            [_companyArr addObject:company];
        }
    }
    if(_companyArr.count == 0)
        _tableView.tableFooterView = _noDataView;
    else
        _tableView.tableFooterView = [UIView new];
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _companyArr.count;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.alpha = 0;
    [UIView animateWithDuration:0.6 animations:^{ cell.alpha = 1; }];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BushManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BushManagerCell" forIndexPath:indexPath];
    Company * item = _companyArr[indexPath.row];
    cell.data = item;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
    BushDetailController *bushDetail = [story instantiateViewControllerWithIdentifier:@"BushDetailController"];
    bushDetail.data = _companyArr[indexPath.row];
    [self.navigationController pushViewController:bushDetail animated:YES];
}
@end
