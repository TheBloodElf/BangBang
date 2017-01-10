//
//  IdentityManager.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "IdentityManager.h"

@implementation IdentityManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
+ (instancetype)manager {
    static IdentityManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IdentityManager alloc] init];
    });
    return manager;
}
- (void)readAuthorizeData {
    self.identity = [DataCache loadCache:@"IdentityLocCache"];
    if(!self.identity) {
        self.identity = [Identity new];
    }
}
- (void)saveAuthorizeData {
    [DataCache setCache:self.identity forKey:@"IdentityLocCache"];
    //把登录信息放到应用组间共享数据  用于扩展和主应用共享数据
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.lottak.bangbang"];
    [NSKeyedArchiver setClassName:@"Identity" forClass:[Identity class]];
    [sharedDefaults setValue:[NSKeyedArchiver archivedDataWithRootObject:self.identity] forKey:@"GroupIdentityInfo"];
    [sharedDefaults synchronize];
}
- (void)logOut {
    //登录模块重新初始化
    IdentityManager *manager = [IdentityManager manager];
    //#1012 这里不能重新初始化，只能把用户guid重制，因为可能还有请求发生
    manager.identity.user_guid = @"";
    [manager saveAuthorizeData];
    //停止个推
    [GeTuiSdk destroy];
    //退出融云
    [[RCIM sharedRCIM] logout];
    //取消所有的本地推送
    NSArray<UILocalNotification *> *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *cation in scheduledLocalNotifications) {
        [[UIApplication sharedApplication] cancelLocalNotification:cation];
    }
}
- (void)showLogin:(NSString *)alertStr {
     [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLogin" object:alertStr];
}

@end
