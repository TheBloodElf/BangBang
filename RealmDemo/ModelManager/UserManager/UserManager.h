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

@interface UserManager : NSObject
//全局的用户信息
@property (nonatomic, strong) User *user;

+ (instancetype)manager;
//更新用户数据
- (void)updateUser:(User*)user;
//通过用户guid加载用户
- (void)loadUserWithGuid:(NSString*)userGuid;
//创建用户的数据库观察者
- (RBQFetchedResultsController*)createUserFetchedResultsController;

@end
