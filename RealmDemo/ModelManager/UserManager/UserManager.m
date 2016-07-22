//
//  UserManager.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UserManager.h"

@interface UserManager () {
    RLMRealm *_rlmRealm;
}

@end

@implementation UserManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)manager {
    static UserManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserManager alloc] init];
    });
    return manager;
}
#pragma mark -- User
//更新用户数据
- (void)updateUser:(User*)user {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addOrUpdateObject:user];
    self.user = user;
    [_rlmRealm commitWriteTransaction];
}
//通过用户guid加载用户
- (void)loadUserWithGuid:(NSString*)userGuid {
    //得到用户对应的数据库路径
    NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *pathUrl = pathArr[0];
    pathUrl = [pathUrl stringByAppendingPathComponent:userGuid];
    //创建数据库
    _rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:pathUrl]];
    //得到/创建用户数据
    RLMResults *users = [User allObjectsInRealm:_rlmRealm];
    if(users.count) {
        self.user = [users objectAtIndex:0];
    } else {
        self.user = [User new];
    }
}
//创建用户的数据库观察者
- (RBQFetchedResultsController*)createUserFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_guid = %@",_user.user_guid];
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"User" inRealm:_rlmRealm predicate:predicate];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:@"User"];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
//根据Guid和圈子ID获取员工
- (Employee*)getEmployeeWithGuid:(NSString*)userGuid companyNo:(int)companyNo {
    [_rlmRealm beginWriteTransaction];
    NSPredicate *pred  = [NSPredicate predicateWithFormat:@"user_guid = %@ and company_no = %d",userGuid,companyNo];
    RLMResults *results = [Employee objectsInRealm:_rlmRealm withPredicate:pred];
    [_rlmRealm commitWriteTransaction];
    //如果有值就返回 没有就算了
    if(results.count)
        return [results objectAtIndex:0];
    return nil;
}
//根据UserNO获取员工
- (Employee*)getEmployeeWithNo:(int)userNo {
    [_rlmRealm beginWriteTransaction];
    RLMResults *results = [Employee objectsInRealm:_rlmRealm withPredicate:nil];
    [_rlmRealm commitWriteTransaction];
    //如果有值就返回 没有就算了
    if(results.count) {
        for (int i = 0;i < results.count;i ++) {
            Employee *employee = [results objectAtIndex:i];
            if(employee.user_no == userNo)
                return employee;
        }
    }
    return nil;
}
#pragma mark -- Company
//更新某个圈子信息
- (void)updateCompany:(Company*)company {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addOrUpdateObject:company];
    [_rlmRealm commitWriteTransaction];
}
//添加某个圈子
- (void)addCompany:(Company*)company {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addObject:company];
    [_rlmRealm commitWriteTransaction];
}
//删除某个圈子
- (void)deleteCompany:(Company*)company {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm deleteObject:company];
    [_rlmRealm commitWriteTransaction];
}
//更新所有圈子数据
- (void)updateCompanyArr:(NSArray<Company*>*)companyArr {
    [_rlmRealm beginWriteTransaction];
    RLMResults *companys = [Company allObjectsInRealm:_rlmRealm];
    while (companys.count)
        [_rlmRealm deleteObject:companys.firstObject];
    [_rlmRealm addObjects:companyArr];
    [_rlmRealm commitWriteTransaction];
}
//获取圈子数组
- (NSMutableArray<Company*>*)getCompanyArr {
    NSMutableArray<Company*> *companyArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    RLMResults *companys = [Company allObjectsInRealm:_rlmRealm];
    for (int index = 0;index < companys.count;index ++) {
        Company *company = [companys objectAtIndex:index];
        [companyArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return companyArr;
}
//创建圈子的数据库观察者
- (RBQFetchedResultsController*)createCompanyFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Company" inRealm:_rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:@"Company"];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- Employee
//更新某个员工
- (void)updateEmployee:(Employee*)emplyee {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addOrUpdateObject:emplyee];
    [_rlmRealm commitWriteTransaction];
}
//根据圈子ID更新所有员工信息
- (void)updateEmployee:(NSMutableArray<Employee*>*)employeeArr companyNo:(int)companyNo{
    [_rlmRealm beginWriteTransaction];
    NSPredicate *pred = nil;
    //如果有圈子id就查询指定圈子员工 如果有状态就查询状态
    if(companyNo)
        pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
    RLMResults *results = [Employee objectsInRealm:_rlmRealm withPredicate:pred];
    while (results.count)
        [_rlmRealm deleteObject:results.firstObject];
    for (Employee * employee in employeeArr) {
        [_rlmRealm addOrUpdateObject:employee];
    }
    [_rlmRealm commitWriteTransaction];
}
//根据圈子ID获取员工信息
- (NSMutableArray<Employee*>*)getEmployeeWithCompanyNo:(int)companyNo status:(int)status{
    NSMutableArray *array = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    NSPredicate *pred = nil;
    //如果有圈子id就查询指定圈子员工 如果有状态就查询状态
    if(companyNo) {
        if(status == -1) {
            pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
        } else {
            pred = [NSPredicate predicateWithFormat:@"company_no = %d and status = %d",companyNo,status];
        }
    } else {
        if(status == -1) {
           
        } else {
            pred = [NSPredicate predicateWithFormat:@"status = %d",status];
        }
    }
    RLMResults *results = [Employee objectsInRealm:_rlmRealm withPredicate:pred];
    for (int index = 0;index < results.count;index ++) {
        Employee *employee = [results objectAtIndex:index];
        [array addObject:employee];
    }
    [_rlmRealm commitWriteTransaction];
    return array;
}
//根据圈子和状态创建数据库监听
- (RBQFetchedResultsController*)createEmployeesFetchedResultsControllerWithCompanyNo:(int)companyNo status:(int)status {
    RBQFetchedResultsController *fetchedResultsController = nil;
    NSPredicate *pred = nil;
    //如果有圈子id就查询指定圈子员工 如果有状态就查询状态
    if(companyNo) {
        if(status == -1) {
            pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
        } else {
            pred = [NSPredicate predicateWithFormat:@"company_no = %d and status = %d",companyNo,status];
        }
    } else {
        if(status == -1) {
            
        } else {
            pred = [NSPredicate predicateWithFormat:@"status = %d",status];
        }
    }
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Employee" inRealm:_rlmRealm predicate:pred];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:@"Employee"];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- PushMessage
//添加某个推送消息
- (void)addPushMessage:(PushMessage*)pushMessage {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addObject:pushMessage];
    [_rlmRealm commitWriteTransaction];
}
//修改某个推送消息
- (void)updatePushMessage:(PushMessage*)pushMessage {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addOrUpdateObject:pushMessage];
    [_rlmRealm commitWriteTransaction];
}
//删除某个推送消息
- (void)deletePushMessage:(PushMessage*)pushMessage {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm deleteObject:pushMessage];
    [_rlmRealm commitWriteTransaction];
}
//获取所有的推送消息
- (NSMutableArray<PushMessage*>*)getPushMessageArr {
    NSMutableArray<PushMessage*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [PushMessage allObjectsInRealm:_rlmRealm];
    for (int index = 0;index < pushMessages.count;index ++) {
        PushMessage *company = [pushMessages objectAtIndex:index];
        [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//创建消息数据监听
- (RBQFetchedResultsController*)createPushMessagesFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"PushMessage" inRealm:_rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:@"PushMessage"];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- UserDiscuss
//添加通讯录中的讨论组
- (void)addUserDiscuss:(UserDiscuss*)userDiscuss {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addObject:userDiscuss];
    [_rlmRealm commitWriteTransaction];
}
//删除通讯录中的讨论组
- (void)deleteUserDiscuss:(UserDiscuss*)userDiscuss {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm deleteObject:userDiscuss];
    [_rlmRealm commitWriteTransaction];
}
//更新所有讨论组
- (void)updateUserDiscussArr:(NSMutableArray<UserDiscuss*>*)userDiscussArr {
    [_rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [UserDiscuss allObjectsInRealm:_rlmRealm];
    while (pushMessages.count)
        [_rlmRealm deleteObject:pushMessages.firstObject];
    [_rlmRealm addObjects:userDiscussArr];
    [_rlmRealm commitWriteTransaction];
}
//获取所有的讨论组
- (NSMutableArray<UserDiscuss*>*)getUserDiscussArr {
    NSMutableArray<UserDiscuss*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [UserDiscuss allObjectsInRealm:_rlmRealm];
    for (int index = 0;index < pushMessages.count;index ++) {
        UserDiscuss *company = [pushMessages objectAtIndex:index];
        [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//创建讨论组数据监听
- (RBQFetchedResultsController*)createUserDiscusFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"UserDiscuss" inRealm:_rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:@"UserDiscuss"];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- Calendar
//添加日程
- (void)addCalendar:(Calendar*)calendar {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addObject:calendar];
    [_rlmRealm commitWriteTransaction];
}
//更新日程
- (void)updateCalendar:(Calendar*)calendar {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addOrUpdateObject:calendar];
    [_rlmRealm commitWriteTransaction];
}
//更新所有的日程
- (void)updateCalendars:(NSMutableArray<Calendar*>*)calendarArr {
    [_rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [Calendar allObjectsInRealm:_rlmRealm];
    while (pushMessages.count)
        [_rlmRealm deleteObject:pushMessages.firstObject];
    for (Calendar *calendar in calendarArr) {
        [_rlmRealm addOrUpdateObject:calendar];
    }
    [_rlmRealm commitWriteTransaction];
}
//获取指定时间的日程 未删除的
- (NSMutableArray<Calendar*>*)getCalendarArrWithDate:(NSDate*)date {
    NSMutableArray<Calendar*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    NSUInteger dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    NSUInteger dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSString *resultStr = [NSString stringWithFormat:@"((enddate_utc >= %ld and begindate_utc <= %ld ) or (enddate_utc >= %ld and begindate_utc <= %ld ) or (enddate_utc <= %ld and begindate_utc >= %ld ) or (r_end_date_utc >= %ld and r_begin_date_utc <= %ld ) or (r_end_date_utc >= %ld and r_begin_date_utc <= %ld ) or (r_end_date_utc <= %ld and r_begin_date_utc >= %ld ))",dateLastTime,dateLastTime,dateFirstTime,dateFirstTime,dateLastTime,dateFirstTime,dateLastTime,dateLastTime,dateFirstTime,dateFirstTime,dateLastTime,dateFirstTime];
    RLMResults *calendarResult = [Calendar objectsInRealm:_rlmRealm where:resultStr];
    for (int index = 0;index < calendarResult.count;index ++) {
        Calendar *company = [calendarResult objectAtIndex:index];
        if(company.status != 0)
            [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//获取所有未删除的日程
- (NSMutableArray<Calendar*>*)getCalendarArr {
    NSMutableArray<Calendar*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [Calendar allObjectsInRealm:_rlmRealm];
    for (int index = 0;index < pushMessages.count;index ++) {
        Calendar *company = [pushMessages objectAtIndex:index];
        if (company.status != 0)
            [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//创建日程数据监听
- (RBQFetchedResultsController*)createCalendarFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Calendar" inRealm:_rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:@"Calendar"];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- SignIn
//更新今天的签到记录
- (void)updateTodaySinInList:(NSMutableArray<SignIn*>*)sigInArr guid:(NSString*)employeeGuid{
    [_rlmRealm beginWriteTransaction];
    NSDate *date = [NSDate date];
    NSUInteger dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    NSUInteger dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(employee_guid = %@ and create_on_utc >= %ld and create_on_utc <= %ld)",employeeGuid,dateFirstTime,dateLastTime];
    RLMResults *calendarResult = [SignIn objectsInRealm:_rlmRealm withPredicate:predicate];
    while (calendarResult.count) {
        [_rlmRealm deleteObject:calendarResult.firstObject];
    }
    [_rlmRealm addObjects:sigInArr];
    [_rlmRealm commitWriteTransaction];
}
//获取今天的签到记录
- (NSMutableArray<SignIn*>*)getTodaySigInListGuid:(NSString*)employeeGuid {
    NSMutableArray<SignIn*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    NSDate *date = [NSDate date];
    NSUInteger dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    NSUInteger dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(employee_guid = %@ and create_on_utc >= %ld and create_on_utc <= %ld)",employeeGuid,dateFirstTime,dateLastTime];
    RLMResults *calendarResult = [SignIn objectsInRealm:_rlmRealm withPredicate:predicate];
    for (int index = 0;index < calendarResult.count;index ++) {
        SignIn *company = [calendarResult objectAtIndex:index];
        [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//创建日程数据监听
- (RBQFetchedResultsController*)createSigInListFetchedResultsController:(NSString*)employeeGuid {
    RBQFetchedResultsController *fetchedResultsController = nil;
    NSDate *date = [NSDate date];
    NSUInteger dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    NSUInteger dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(employee_guid = %@ and create_on_utc >= %ld and create_on_utc <= %ld)",employeeGuid,dateFirstTime,dateLastTime];
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"SignIn" inRealm:_rlmRealm predicate:predicate];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:@"SignIn"];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- SiginRuleSet
//更新签到规则
- (void)updateSiginRule:(SiginRuleSet*)siginRule {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addOrUpdateObject:siginRule];
    [_rlmRealm commitWriteTransaction];
}
//添加签到规则
- (void)addSiginRule:(SiginRuleSet*)siginRule {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm addObject:siginRule];
    [_rlmRealm commitWriteTransaction];
}
//删除签到规则
- (void)deleteSiginRule:(SiginRuleSet*)siginRule {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm deleteObject:siginRule];
    [_rlmRealm commitWriteTransaction];
}
//获取圈子的所有签到规则
- (NSMutableArray<SiginRuleSet*>*)getSiginRule:(int)companyNo {
    NSMutableArray *array = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d )",companyNo];
    RLMResults *calendarResult = [SiginRuleSet objectsInRealm:_rlmRealm withPredicate:predicate];
    for (int i = 0; i < calendarResult.count; i ++) {
        [array addObject:[calendarResult objectAtIndex:i]];
    }
    [_rlmRealm commitWriteTransaction];
    return array;
}
//更新圈子的所有签到规则
- (void)updateSiginRule:(NSMutableArray<SiginRuleSet*>*)sigRules companyNo:(int)companyNo {
    [_rlmRealm beginWriteTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d )",companyNo];
    RLMResults *calendarResult = [SiginRuleSet objectsInRealm:_rlmRealm withPredicate:predicate];
    while (calendarResult.count) {
        [_rlmRealm deleteObject:calendarResult.firstObject];
    }
    [_rlmRealm addObjects:sigRules];
    [_rlmRealm commitWriteTransaction];
}
//创建圈子的数据监听
- (RBQFetchedResultsController*)createSiginRuleFetchedResultsController:(int)companyNo {
    RBQFetchedResultsController *fetchedResultsController = nil;
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d )",companyNo];
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"SiginRuleSet" inRealm:_rlmRealm predicate:predicate];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:@"SiginRuleSet"];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
@end
