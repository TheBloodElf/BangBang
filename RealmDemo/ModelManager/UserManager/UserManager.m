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
@end
