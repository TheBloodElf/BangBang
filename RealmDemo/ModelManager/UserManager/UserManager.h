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
#import "PushMessage.h"
#import "UserDiscuss.h"
#import "Calendar.h"
#import "SignIn.h"
#import "SiginRuleSet.h"
#import "TaskModel.h"

@interface UserManager : NSObject

//全局的用户信息
@property (nonatomic, strong) User *user;

+ (instancetype)manager;

#pragma makr -- 本地推送
//添加上下班通知
- (void)addSiginRuleNotfition;
//添加日程通知
- (void)addCalendarNotfition;
//添加任务通知
- (void)addTaskNotfition;
#pragma mark -- User
//更新用户数据
- (void)updateUser:(User*)user;
//通过用户guid加载用户
- (void)loadUserWithGuid:(NSString*)userGuid;
//创建用户的数据库观察者
- (RBQFetchedResultsController*)createUserFetchedResultsController;
//获取所有员工
- (NSMutableArray<Employee*>*)getEmployeeArr;
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
- (RBQFetchedResultsController*)createEmployeesFetchedResultsControllerWithCompanyNo:(int)companyNo;
#pragma mark -- PushMessage
//添加某个推送消息
- (void)addPushMessage:(PushMessage*)pushMessage;
//修改某个推送消息
- (void)updatePushMessage:(PushMessage*)pushMessage;
//删除某个推送消息
- (void)deletePushMessage:(PushMessage*)pushMessage;
//获取所有的推送消息
- (NSMutableArray<PushMessage*>*)getPushMessageArr;
//创建消息数据监听
- (RBQFetchedResultsController*)createPushMessagesFetchedResultsController;
#pragma mark -- UserDiscuss
//添加通讯录中的讨论组
- (void)addUserDiscuss:(UserDiscuss*)userDiscuss;
//删除通讯录中的讨论组
- (void)deleteUserDiscuss:(UserDiscuss*)userDiscuss;
//获取所有的讨论组
- (NSMutableArray<UserDiscuss*>*)getUserDiscussArr;
//更新所有讨论组
- (void)updateUserDiscussArr:(NSMutableArray<UserDiscuss*>*)userDiscussArr;
//创建讨论组数据监听
- (RBQFetchedResultsController*)createUserDiscusFetchedResultsController;
#pragma mark -- Calendar
//添加日程
- (void)addCalendar:(Calendar*)calendar;
//更新日程
- (void)updateCalendar:(Calendar*)calendar;
//删除日程
- (void)delCalendar:(Calendar*)calendar;
//更新所有的日程
- (void)updateCalendars:(NSMutableArray<Calendar*>*)calendarArr;
//获取指定时间的日程 未删除的
- (NSMutableArray<Calendar*>*)getCalendarArrWithDate:(NSDate*)date;
//获取所有的日程
- (NSMutableArray<Calendar*>*)getCalendarArr;
//创建日程数据监听
- (RBQFetchedResultsController*)createCalendarFetchedResultsController;
#pragma mark -- SignIn
//添加签到记录
- (void)addSigin:(SignIn*)signIn;
//更新今天的签到记录
- (void)updateTodaySinInList:(NSMutableArray<SignIn*>*)sigInArr guid:(NSString*)employeeGuid;
//获取今天的签到记录
- (NSMutableArray<SignIn*>*)getTodaySigInListGuid:(NSString*)employeeGuid;
//创建日程数据监听
- (RBQFetchedResultsController*)createSigInListFetchedResultsController:(NSString*)employeeGuid;
#pragma mark -- SiginRuleSet
//更新签到规则
- (void)updateSiginRule:(SiginRuleSet*)siginRule;
//添加签到规则
- (void)addSiginRule:(SiginRuleSet*)siginRule;
//删除签到规则
- (void)deleteSiginRule:(SiginRuleSet*)siginRule;
//获取圈子的所有签到规则
- (NSMutableArray<SiginRuleSet*>*)getSiginRule:(int)companyNo;
//更新圈子的所有签到规则
- (void)updateSiginRule:(NSMutableArray<SiginRuleSet*>*)sigRules companyNo:(int)companyNo;
//创建圈子的数据监听
- (RBQFetchedResultsController*)createSiginRuleFetchedResultsController:(int)companyNo;
#pragma mark -- TaskModel
//添加任务
- (void)addTask:(TaskModel*)model;
//更新任务
- (void)upadteTask:(TaskModel*)model;
//更新圈子的任务
- (void)updateTask:(NSMutableArray<TaskModel*>*)taskArr companyNo:(int)companyNo;
//获取所有的任务列表
- (NSMutableArray<TaskModel*>*)getTaskArr:(int)companyNo;
//任务数据监听
- (RBQFetchedResultsController*)createTaskFetchedResultsController:(int)companyNo;
@end
