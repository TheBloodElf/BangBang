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
//根据圈子ID更新员工信息
- (void)updateEmployee:(NSMutableArray<Employee*>*)employeeArr companyID:(int)companyID;
//根据圈子ID获取员工信息
- (NSMutableArray<Employee*>*)getEmployeeWithCompanyID:(int)companyID;
@end
