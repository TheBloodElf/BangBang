//
//  ApnsManager.m
//  RealmDemo
//
//  Created by Mac on 16/7/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ApnsManager.h"
#import "UserManager.h"
#import "IdentityManager.h"

@interface ApnsManager () {
    UserManager *_userManager;
}

@end

@implementation ApnsManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        _userManager = [UserManager manager];
    }
    return self;
}

+ (instancetype)manager {
    static ApnsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ApnsManager alloc] init];
    });
    return manager;
}

//注册通知
- (void)registerNotification {
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge |UIUserNotificationTypeSound |UIUserNotificationTypeAlert)categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
//收到本地推送
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    IdentityManager *identityManager = [IdentityManager manager];
    if (identityManager.identity.canPlayVoice != 1) {
        AudioServicesPlaySystemSound(1007); //系统的通知声音
    }
    if (identityManager.identity.canPlayShake != 1) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);//震动
    }
    if ([notification.alertBody hasPrefix:@"任务提醒:"]||[notification.alertBody hasPrefix:@"事务提醒:"] || [notification.alertBody hasPrefix:@"上下班提醒:"]) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"notification_ring" ofType:@"mp3"];
            NSURL *url = [NSURL URLWithString:path];
            SystemSoundID ID;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &ID);
            AudioServicesPlayAlertSound(ID);
        }
    }
    if([notification.alertBody hasPrefix:@"任务提醒:"]||[notification.alertBody hasPrefix:@"事务提醒:"]) {
        PushMessage *pushMessage = [PushMessage new];
        [pushMessage mj_setKeyValues:notification.userInfo];
        [_userManager addPushMessage:pushMessage];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecivePushMessage" object:pushMessage];
        // 图标上的数字减1
        application.applicationIconBadgeNumber -= 1;
    }
}

@end
