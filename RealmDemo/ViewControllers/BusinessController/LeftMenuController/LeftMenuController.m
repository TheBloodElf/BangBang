//
//  LeftMenuController.m
//  RealmDemo
//
//  Created by Mac on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "LeftMenuController.h"
#import "UserManager.h"
#import "MineInfoEditController.h"
#import "BushSearchViewController.h"
#import "LeftMenuOpertion.h"

@interface LeftMenuController () {
    UserManager *_userManager;//用户管理器
    LeftMenuOpertion *_leftMenuOpertion;//本页面显示和某些操作的封装
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据库监听
    RBQFetchedResultsController *_commpanyFetchedResultsController;//圈子数据监听
}

@end

@implementation LeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.avaterImageView zy_cornerRadiusRoundingRect];
    self.view.backgroundColor = [UIColor clearColor];
    _userManager  = [UserManager manager];
    _leftMenuOpertion = [LeftMenuOpertion new];
    _leftMenuOpertion.viewController = self;
    [_leftMenuOpertion startConnect];
    //创建数据监听
    _commpanyFetchedResultsController = [_userManager createCompanyFetchedResultsController];
    _commpanyFetchedResultsController.data = @"commpanyFetchedResultsController";
    _commpanyFetchedResultsController.delegate = _leftMenuOpertion;
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.data = @"userFetchedResultsController";
    _userFetchedResultsController.delegate = _leftMenuOpertion;
    //设置表格视图
    self.tableView.delegate = _leftMenuOpertion;
    self.tableView.dataSource = _leftMenuOpertion;
    [self.tableView registerNib:[UINib nibWithNibName:@"LeftMenuCell" bundle:nil] forCellReuseIdentifier:@"LeftMenuCell"];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
    // Do any additional setup after loading the view from its nib.
}
//加入圈子被点击
- (IBAction)joinCompanyClicked:(id)sender {
    BushSearchViewController *bush = [BushSearchViewController new];
    [self.navigationController pushViewController:bush animated:YES];
    //隐藏菜单控制器
    [self.frostedViewController hideMenuViewController];
}
//头像被点击
- (IBAction)avaterClicked:(id)sender {
    MineInfoEditController *mine = [MineInfoEditController new];
    [self.navigationController pushViewController:mine animated:YES];
    //隐藏菜单控制器
    [self.frostedViewController hideMenuViewController];
}

@end
