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
#import "DotActivityIndicatorView.h"
#import "NoResultView.h"

@interface BushManageViewController ()<UITableViewDataSource,UITableViewDelegate,RBQFetchedResultsControllerDelegate,MoreSelectViewDelegate> {
    UserManager *_userManager;//用户管理器
    UITableView *_tableView;//展示数据的表格视图
    NSMutableArray<Company*> *_companyArr;//圈子数组
    RBQFetchedResultsController *_companyFetchedResultsController;//圈子数据监听
    NoResultView *_noDataView;//没有数据显示的视图
    MoreSelectView *_moreSelectView;//多选视图
    
    BOOL _isFirstLoad;
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
    DotActivityIndicatorView *loadView = [[DotActivityIndicatorView alloc] initWithFrame:_tableView.bounds];
    _tableView.tableFooterView = loadView;
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
                Company *company = [Company new];
                [company mj_setKeyValues:dic];
                [companys addObject:company];
            }
            [_userManager updateCompanyArr:companys];
        }];
    }];
    //创建空太图
    _noDataView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    [_noDataView setNoResultStr:@"还未加入任何圈子"];
    //创建多选视图
    _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 5, 5, 100, 45 * 2)];
    _moreSelectView.selectArr = @[@"加入圈子",@"创建圈子"];
    _moreSelectView.delegate = self;
    _moreSelectView.tag = 10000;
    [_moreSelectView setupUI];
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
    //创建右边导航按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClicked:)];
    //测试按钮
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
//    [button setTitle:@"测试按钮" forState:UIControlStateNormal];
//    button.frame = CGRectMake(0, 64, 100, 100);
//    button.backgroundColor = [UIColor redColor];
//    button.tag = 100000;
//    [self.view addSubview:button];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_isFirstLoad == YES) return;
    _isFirstLoad = YES;
    //只显示自己状态为4或者1的
    for (Company *company in [_userManager getCompanyArr]) {
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
- (void)rightBarButtonClicked:(UIBarButtonItem*)item {
    if(_moreSelectView.isHide)
        [_moreSelectView showSelectView];
    else
        [_moreSelectView hideSelectView];
}
//#pragma mark --
//#pragma mark -- UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    UIButton *button = [self.view viewWithTag:100000];
//    button.hidden = YES;
//}
//- (void)scrollViewDidEndDec、elerating:(UIScrollView *)scrollView {
//    UIButton *button = [self.view viewWithTag:100000];
//    button.hidden = NO;
//}
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
    NSMutableArray *array = [@[] mutableCopy];
    //只显示自己状态为4或者1的
    for (Company *company in [_userManager getCompanyArr]) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
        if(employee.status == 1 || employee.status == 4) {
            [array addObject:company];
        }
    }
    _companyArr = array;
    if(_companyArr.count == 0)
        _tableView.tableFooterView = _noDataView;
    else
        _tableView.tableFooterView = [UIView new];
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _companyArr.count;
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
