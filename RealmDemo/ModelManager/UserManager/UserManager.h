//
//  UserManager.h
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import <RBQFetchedResultsController/RBQFRC.h>
#import "User.h"
#import "Company.h"
#import "Employee.h"

@interface UserManager : NSObject
//全局的用户信息
@property (nonatomic, strong) User *user;

+ (instancetype)manager;
#pragma mark -- User
//更新用户数据
- (void)updateUser:(User*)user;
//通过用户guid加载用户
- (void)loadUserWithGuid:(NSString*)userGuid;
//创建用户的数据库观察者
- (RBQFetchedResultsController*)createUserFetchedResultsController;
//根据Guid和圈子ID获取员工
- (Employee*)getEmployeeWithGuid:(NSString*)userGuid companyNo:(int)companyNo;
#pragma mark -- Company
//更新某个圈子信息
- (void)updateCompany:(Company*)company;
//添加某个圈子
- (void)addCompany:(Company*)company;
//删除某个圈子
- (void)deleteCompany:(Company*)company;
//更新所有圈子数据
- (void)updateCompanyArr:(NSArray<Company*>*)companyArr;
//获取圈子数组
- (NSMutableArray<Company*>*)getCompanyArr;
//创建圈子的数据库观察者
- (RBQFetchedResultsController*)createCompanyFetchedResultsController;
#pragma mark -- Employee
//更新某个员工
- (void)updateEmployee:(Employee*)emplyee;
//根据圈子NO更新所有员工信息
- (void)updateEmployee:(NSMutableArray<Employee*>*)employeeArr companyNo:(int)companyNo;
//根据圈子NO获取员工数组 状态为－1查询所有状态
- (NSMutableArray<Employee*>*)getEmployeeWithCompanyNo:(int)companNo status:(int)status;
//根据圈子和状态创建数据库监听 主要用于申请管理用
- (RBQFetchedResultsController*)createEmployeesFetchedResultsControllerWithCompanyNo:(int)companyNo status:(int)status;
@end
