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

@interface BushSearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,BushSearchCellDelegate>{
    UserManager *_userManager;
    UIView *_noDataView;//没有数据应该显示的内容
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
    self.searchBar.text = @"琅拓科";
    self.searchBar.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:self.searchBar];
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,  55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 55) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView registerNib:[UINib nibWithNibName:@"BushSearchCell" bundle:nil] forCellReuseIdentifier:@"BushSearchCell"];
    [self.view addSubview:_tableView];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        currentPage = 1;
        [self search];
    }];
    //创建空太图
    _noDataView = [[UIView alloc] initWithFrame:_tableView.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0.33 * (_tableView.frame.size.height - 10), _tableView.frame.size.width, 10)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"未找到你想要的内容";
    [_noDataView addSubview:label];
    //创建导航按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonClicked:)];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //因为圈子详情可能会有修改那些操作，所以就要实时的更新下
    [_tableView reloadData];
}
//从网上加载数据
- (void)search {
    if([NSString isBlank:self.searchBar.text]) {
        [_tableView.mj_header endRefreshing];
        _tableView.mj_footer = (id)_noDataView;
        [_companyArr removeAllObjects];
        [_tableView reloadData];
        return;
    }
    [UserHttp getCompanyList:self.searchBar.text pageSize:20 pageIndex:currentPage handler:^(id data, MError *error) {
        if(_tableView.mj_footer != _noDataView)
            [_tableView.mj_footer endRefreshing];
        [_tableView.mj_header endRefreshing];
        if(error) {
            [self.navigationController.view showMessageTips:error.statsMsg];
            return ;
        }
        if(currentPage == 1)
            [_companyArr removeAllObjects];
        for (NSDictionary *dic in data[@"list"]) {
            Company *company = [[Company alloc] initWithJSONDictionary:dic];
            [_companyArr addObject:company];
        }
        if(_companyArr.count == 0) {
            _tableView.tableFooterView = _noDataView;
        } else {
            _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                currentPage ++;
                [self search];
            }];
        }
        [_tableView reloadData];
    }];
}
- (void)rightBarButtonClicked:(UIBarButtonItem*)item {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MineView" bundle:nil];
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
        [UserHttp joinCompany:model.company_no userGuid:_userManager.user.user_guid joinReason:field.text handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            //这里要把这个圈子加入到本地 员工信息加入到本地
            [_userManager addCompany:model];
            [UserHttp getEmployeeCompnyNo:model.company_no status:0 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                NSMutableArray *array = [@[] mutableCopy];
                for (NSDictionary *dic in data[@"list"]) {
                    Employee *employee = [[Employee alloc] initWithJSONDictionary:dic];
                    [array addObject:employee];
                }
                [UserHttp getEmployeeCompnyNo:model.company_no status:5 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                    if(error) {
                        [self.navigationController.view showFailureTips:error.statsMsg];
                        return ;
                    }
                    for (NSDictionary *dic in data[@"list"]) {
                        Employee *employee = [[Employee alloc] initWithJSONDictionary:dic];
                        [array addObject:employee];
                    }
                    [_userManager updateEmployee:array companyNo:model.company_no];
                    [self.navigationController showSuccessTips:@"请求已发出，请等待"];
                    [self.navigationController popViewControllerAnimated:YES];
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
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MineView" bundle:nil];
    BushDetailController *vc = [story instantiateViewControllerWithIdentifier:@"BushDetailController"];
    vc.data = [_companyArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
