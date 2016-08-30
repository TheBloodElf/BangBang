//
//  LeftMenuOpertion.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "LeftMenuOpertion.h"

@interface LeftMenuOpertion () {
    UserManager *_userManager;
    NSMutableArray<Company*> *_companyArr;//圈子数组
}

@end

@implementation LeftMenuOpertion

- (void)startConnect {
    _userManager = [UserManager manager];
    _companyArr = [@[] mutableCopy];
    //设置圈子信息 只显示自己状态为1或者4的
    for (Company *company in [_userManager getCompanyArr]) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
        if(employee.status == 1 || employee.status == 4) {
            [_companyArr addObject:company];
        }
    }
    //设置用户信息
    [self.viewController.avaterImageView sd_setImageWithURL:[NSURL URLWithString:_userManager.user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.viewController.userName.text = _userManager.user.real_name;
    self.viewController.userMood.text = _userManager.user.mood;
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if([controller.data isEqualToString:@"userFetchedResultsController"]) {
        [self.viewController.avaterImageView sd_setImageWithURL:[NSURL URLWithString:_userManager.user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        self.viewController.userName.text = _userManager.user.real_name;
        self.viewController.userMood.text = _userManager.user.mood;
        [self.viewController.tableView reloadData];//圈子变化了也要刷新表格视图
    } else {
        [_companyArr removeAllObjects];
        //只显示自己状态为4或者1的
        for (Company *company in [_userManager getCompanyArr]) {
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
            if(employee.status == 1 || employee.status == 4) {
                [_companyArr addObject:company];
            }
        }
        [self.viewController.tableView reloadData];
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
    user.currCompany = [company deepCopy];
    [_userManager updateUser:user];
    //刷新表格视图
    [tableView reloadData];
    //隐藏菜单控制器
    [self.viewController.frostedViewController hideMenuViewController];
}
@end
