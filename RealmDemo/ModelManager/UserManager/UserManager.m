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
#pragma mark -- Company
//更新圈子数据
- (void)updateCompanyArr:(NSArray<Company*>*)companyArr {
    [_rlmRealm beginWriteTransaction];
    RLMResults *companys = [Company allObjectsInRealm:_rlmRealm];
    for (int index = 0;index < companys.count;index ++) {
        Company *company = [companys objectAtIndex:index];
        [_rlmRealm deleteObject:company];
    }
    [_rlmRealm addObjects:companyArr];
    [_rlmRealm commitWriteTransaction];
}
//创建圈子的数据库观察者
- (RBQFetchedResultsController*)createCompanyFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Company" inRealm:_rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:@"Company"];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
@end
