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
#import "LeftMenuCell.h"

@interface LeftMenuController ()<UITableViewDelegate,UITableViewDataSource,RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;//用户管理器
    NSMutableArray<Company*> *_companyArr;//圈子数组
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据库监听
    RBQFetchedResultsController *_commpanyFetchedResultsController;//圈子数据监听
}
@property (weak, nonatomic) IBOutlet UIImageView *avaterImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMood;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation LeftMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _userManager  = [UserManager manager];
    //创建数据监听
    _commpanyFetchedResultsController = [_userManager createCompanyFetchedResultsController];
    _commpanyFetchedResultsController.data = @"commpanyFetchedResultsController";
    _commpanyFetchedResultsController.delegate = self;
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.data = @"userFetchedResultsController";
    _userFetchedResultsController.delegate = self;
    _companyArr = [@[] mutableCopy];
    //设置圈子信息 只显示自己状态为1或者4的
    for (Company *company in [_userManager getCompanyArr]) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
        if(employee.status == 1 || employee.status == 4) {
            [_companyArr addObject:company];
        }
    }
    //设置表格视图
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"LeftMenuCell" bundle:nil] forCellReuseIdentifier:@"LeftMenuCell"];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
    //设置用户信息
    [self.avaterImageView zy_cornerRadiusRoundingRect];
    [self.avaterImageView sd_setImageWithURL:[NSURL URLWithString:_userManager.user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.userName.text = _userManager.user.real_name;
    self.userMood.text = _userManager.user.mood;
    // Do any additional setup after loading the view from its nib.
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if([controller.data isEqualToString:@"userFetchedResultsController"]) {
        [self.avaterImageView sd_setImageWithURL:[NSURL URLWithString:_userManager.user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        self.userName.text = _userManager.user.real_name;
        self.userMood.text = _userManager.user.mood;
        [self.tableView reloadData];//圈子变化了也要刷新表格视图
    } else {
        NSMutableArray *array = [@[] mutableCopy];
        //只显示自己状态为4或者1的
        for (Company *company in [_userManager getCompanyArr]) {
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
            if(employee.status == 1 || employee.status == 4) {
                [array addObject:company];
            }
        }
        _companyArr = array;
        [self.tableView reloadData];
    }
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _companyArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftMenuCell" forIndexPath:indexPath];
    cell.data = _companyArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //改变用户当前圈子
    Company *company = [_companyArr[indexPath.row] deepCopy];
    User *user = [_userManager.user deepCopy];
    user.currCompany = company;
    [_userManager updateUser:user];
    //刷新表格视图
    [tableView reloadData];
    //隐藏菜单控制器
    [self.frostedViewController hideMenuViewController];
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
