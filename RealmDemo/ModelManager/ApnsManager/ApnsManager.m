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
    UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
//    action.identifier = @"完成";//按钮的标示
    action.title=@"完成";//按钮的标题
    action.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
    //    action.authenticationRequired = YES;
    //    action.destructive = YES;
    UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
//    action2.identifier = @"删除";
    action2.title=@"删除";
    action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
    action.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
    action.destructive = YES;
    UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
    categorys.identifier = @"alert";//这组动作的唯一标示
    [categorys setActions:@[action,action2] forContext:(UIUserNotificationActionContextMinimal)];
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:[NSSet setWithObjects:categorys,nil]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
//收到本地推送
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    if([IdentityManager manager].identity.canPlayVoice) {//声音
        // 1.创建SystemSoundID,根据音效文件来生成
        SystemSoundID soundID = 0;
        // 2.根据音效文件,来生成SystemSoundID
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"notification_ring.mp3" withExtension:nil];
        CFURLRef urlRef = (__bridge CFURLRef)(url);
        AudioServicesCreateSystemSoundID(urlRef, &soundID);
        // 播放音效
        AudioServicesPlaySystemSound(soundID);
    }
    if([IdentityManager manager].identity.canPlayShake)//震动
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    
    NSMutableDictionary *dictionary = [notification.userInfo mutableCopy];
    [dictionary setObject:@([NSDate date].timeIntervalSince1970 * 1000).stringValue forKey:@"id"];
    PushMessage *pushMessage = [PushMessage new];
    [pushMessage mj_setKeyValues:dictionary];
    pushMessage.addTime = [NSDate date];
    [_userManager addPushMessage:pushMessage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecivePushMessage" object:pushMessage];
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

@end
