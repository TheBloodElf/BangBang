//
//  IdentityManager.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "IdentityManager.h"
#import "GeTuiSdkManager.h"

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
    //把登录信息放到应用组间共享数据
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.lottak.bangbang"];
    [NSKeyedArchiver setClassName:@"Identity" forClass:[Identity class]];
    [sharedDefaults setValue:[NSKeyedArchiver archivedDataWithRootObject:self.identity] forKey:@"GroupIdentityInfo"];
    [sharedDefaults synchronize];
}
- (void)logOut {
    //登录模块重新初始化
    IdentityManager *manager = [IdentityManager manager];
    manager.identity = [Identity new];
    manager.identity.firstUseSoft = NO;
    [manager saveAuthorizeData];
    //停止个推
    [[GeTuiSdkManager manager] stopGeTuiSdk];
    //退出融云
    [[RCIM sharedRCIM] logout];
}
- (void)showLogin:(NSString *)alertStr {
     [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowLogin" object:alertStr];
}
@end
