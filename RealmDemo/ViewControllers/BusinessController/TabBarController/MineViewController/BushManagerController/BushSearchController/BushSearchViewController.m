//
//  BushSearchViewController.m
//  BangBang
//
//  Created by Kiwaro on 14-12-20.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import "BushSearchViewController.h"
#import "Employee.h"
#import "BushDetailController.h"
#import "CreateBushController.h"
#import "BushSearchCell.h"
#import "UserManager.h"
#import "UserHttp.h"

#import "NoResultView.h"

@interface BushSearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,BushSearchCellDelegate>{
    UserManager *_userManager;
    NoResultView *_noDataView;//没有数据应该显示的内容
    UITableView *_tableView;//展示数据的表格视图
    int currentPage;//搜索的页码
    NSMutableArray<Company*> *_companyArr;//圈子搜索结果
}
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation BushSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"加入圈子";
    _companyArr = [@[] mutableCopy];
    _userManager = [UserManager manager];
    self.view.backgroundColor = [UIColor whiteColor];
    //创建搜索框
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"使用圈子名称搜索圈子";
    self.searchBar.returnKeyType = UIReturnKeySearch;
    [self.searchBar setSearchBarBackgroundColor:[UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1]];
    for(UIView * view in [_searchBar.subviews[0] subviews]) {
        if([view isKindOfClass:[UITextField class]]) {
            [(UITextField*)view setEnablesReturnKeyAutomatically:NO];
            break;
        }
    }
    [self.view addSubview:self.searchBar];
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,  55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 55 - 64) style:UITableViewStylePlain];
    _noDataView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    [_noDataView setNoResultStr:@"对不起，无相关数据"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = _noDataView;
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView registerNib:[UINib nibWithNibName:@"BushSearchCell" bundle:nil] forCellReuseIdentifier:@"BushSearchCell"];
    [self.view addSubview:_tableView];
    WeakSelf(weakSelf)
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        currentPage = 1;
        [weakSelf search];
    }];
    //创建导航按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonClicked:)];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor homeListColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
//从网上加载数据
- (void)search {
    if([NSString isBlank:self.searchBar.text]) {
        [_tableView.mj_header endRefreshing];
        _tableView.mj_footer = (id)_noDataView;
        _companyArr = [@[] mutableCopy];
        [_tableView reloadData];
        return;
    }
    WeakSelf(weakSelf)
    [UserHttp getCompanyList:self.searchBar.text pageSize:20 pageIndex:currentPage handler:^(id data, MError *error) {
        if(_tableView.mj_footer != (id)_noDataView)
            [_tableView.mj_footer endRefreshing];
        [_tableView.mj_header endRefreshing];
        if(error) {
            [weakSelf.navigationController.view showMessageTips:error.statsMsg];
            return ;
        }
        NSMutableArray *array = [@[] mutableCopy];
        if(currentPage != 1)//不是第一页就是要保存前面的数据
            array = _companyArr;
        for (NSDictionary *dic in data) {
            Company *company = [Company new];
            [company mj_setKeyValues:dic];
            [array addObject:company];
        }
        _companyArr = array;
        if(_companyArr.count == 0) {
            _tableView.tableFooterView = _noDataView;
        } else {
            _tableView.tableFooterView = [UIView new];
            _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                currentPage ++;
                [weakSelf search];
            }];
        }
        [_tableView reloadData];
    }];
}
- (void)rightBarButtonClicked:(UIBarButtonItem*)item {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
    CreateBushController *vc = [story instantiateViewControllerWithIdentifier:@"CreateBushController"];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -- 
#pragma mark -- BushSearchCellDelegate
- (void)bushSearchCellJoin:(Company *)model {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"圈子名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入名称...";
        textField.text = [NSString stringWithFormat:@"我是%@，请求加入圈子",_userManager.user.real_name];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *field = alertVC.textFields[0];
        if([NSString isBlank:field.text]) {
           field.text = [NSString stringWithFormat:@"我是%@，请求加入圈子",_userManager.user.real_name];
        }
        WeakSelf(weakSelf)
        [UserHttp joinCompany:model.company_no userGuid:_userManager.user.user_guid joinReason:field.text handler:^(id data, MError *error) {
            if(error) {
                [weakSelf.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            //这里要把这个圈子加入到本地 员工信息加入到本地
            [_userManager addCompany:model];
            [UserHttp getEmployeeCompnyNo:model.company_no status:0 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                if(error) {
                    [weakSelf.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                NSMutableArray *array = [@[] mutableCopy];
                for (NSDictionary *dic in data[@"list"]) {
                    Employee *employee = [Employee new];
                    [employee mj_setKeyValues:dic];
                    [array addObject:employee];
                }
                [UserHttp getEmployeeCompnyNo:model.company_no status:5 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                    if(error) {
                        [weakSelf.navigationController.view showFailureTips:error.statsMsg];
                        return ;
                    }
                    for (NSDictionary *dic in data[@"list"]) {
                        Employee *employee = [Employee new];
                        [employee mj_setKeyValues:dic];
                        [array addObject:employee];
                    }
                    [_userManager updateEmployee:array companyNo:model.company_no];
                    [weakSelf.navigationController showSuccessTips:@"请求已发出，请等待"];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }];
            }];
        }];
    }];
    UIAlertAction *cancleActio = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:cancleActio];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark --
#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)sender {
    [self.searchBar resignFirstResponder];
    [_tableView.mj_header beginRefreshing];
}
#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _companyArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BushSearchCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"BushSearchCell" forIndexPath:indexPath];
    cell.delegate = self;
    Company * item = [_companyArr objectAtIndex:indexPath.row];
    cell.data = item;
    return cell;
}
// 点击查看信息
- (void)tableView:(UITableView *)sender didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [sender deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
    BushDetailController *vc = [story instantiateViewControllerWithIdentifier:@"BushDetailController"];
    vc.data = [_companyArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
