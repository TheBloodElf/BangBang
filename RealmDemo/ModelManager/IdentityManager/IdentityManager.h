//
//  IdentityManager.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Identity.h"

@interface IdentityManager : NSObject

@property (nonatomic, strong) Identity *identity;

+ (instancetype)manager;
//从本地读取登录缓存信息
- (void)readAuthorizeData;
//把登录信息存入本地
- (void)saveAuthorizeData;
//重置登录信息
- (void)resetAuthorizeData;

@end
