//
//  AppDelegate.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/6/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AppDelegate.h"
#import "AppCustoms.h"
#import "MainViewController.h"
#import "IdentityManager.h"
#import "GeTuiSdkManager.h"
#import "ApnsManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Realm数据库版本
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 2;
    [RLMRealmConfiguration setDefaultConfiguration:config];
    //键盘遮挡问题解决方案
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    //百度统计
    [self startBDMobStat];
    //注册微信APPID
    [WXApi registerApp:@"wxbd349c9a6abf20f8" withDescription:@"weixin"];
    //注册微博APPKEY
    [WeiboSDK registerApp:@"3837588781"];
    //Bugtags初始化
    [Bugtags startWithAppKey:BUGTAGSAPPKEY invocationEvent:BugOpen];
    //百度地图注册
    [AMapServices sharedServices].apiKey = @"812f92db9078841bddb73919f07e8d15";
    //对应用进行全局的初始化
    [AppCustoms customs];
    //设置融云代理
    [[RYChatManager shareInstance] registerRYChat];
    //清空应用红点
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //注册远程推送
    [[ApnsManager manager] registerNotification];
    //创建根视图控制器
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [MainViewController new];
    [self.window makeKeyAndVisible];
    //注册3d touch功能
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {//判定系统版本
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKeyedSubscript:UIApplicationLaunchOptionsShortcutItemKey];
        if(shortcutItem) {
            int currIndex = 0;
            if ([shortcutItem.type isEqualToString:@"今日日程"]) {
                currIndex = 0;
            } else if ([shortcutItem.type isEqualToString:@"签到"]) {
                currIndex = 1;
            }
            //发出通知弹出控制器
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormTouch_Notication" object:@(currIndex)];
        }
    }
    return YES;
}
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    int currIndex = 0;
    if ([shortcutItem.type isEqualToString:@"今日日程"]) {
        currIndex = 0;
    } else if ([shortcutItem.type isEqualToString:@"签到"]) {
        currIndex = 1;
    }
    //发出通知弹出控制器
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormTouch_Notication" object:@(currIndex)];
    completionHandler(YES);
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    //是不是从today扩展进来的
    NSString *currStr = url.absoluteString;
    if([[currStr componentsSeparatedByString:@"//"][1] isEqualToString:@"addCalendar"]) {//添加日程
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormToday_addCalendar_Notication" object:nil];
    } else if([[currStr componentsSeparatedByString:@"//"][1] isEqualToString:@"openCalendar"]) {//查看日程
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormToday_openCalendar_Notication" object:[currStr componentsSeparatedByString:@"//"][2]];
    }
    return [TencentOAuth HandleOpenURL:url] || [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]] || [WeiboSDK handleOpenURL:url delegate:[WBApiManager shareManager]];
}
//收到推送token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *currDeviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    //向个推服务器注册deviceToken
    [[GeTuiSdkManager manager] registerDeviceToken:currDeviceToken];
    //注册融云推送
    [[RCIMClient sharedRCIMClient] setDeviceToken:currDeviceToken];
    //保存deviceToken在本地
    [IdentityManager manager].identity.deviceIDAPNS = currDeviceToken;
    [[IdentityManager manager] saveAuthorizeData];
}
//收到本地推送 上下班、任务提醒等
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification  {
    //交给管理器去处理
    [[ApnsManager manager] application:application didReceiveLocalNotification:notification];
}
- (void)startBDMobStat {
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    statTracker.enableExceptionLog = YES; // 是否允许截获并发送崩溃信息，请设置YES或者NO
    statTracker.channelId = BAIDUMOSTATCHANNEL;//设置您的app的发布渠道
    statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch;//根据开发者设定的发送策略,发送日志
    statTracker.logSendInterval = 1;  //为1时表示发送日志的时间间隔为1小时,当logStrategy设置为BaiduMobStatLogStrategyCustom时生效
    statTracker.logSendWifiOnly = YES; //是否仅在WIfi情况下发送日志数据
    statTracker.sessionResumeInterval = 10;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
    statTracker.shortAppVersion  = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [statTracker startWithAppId:@"6a6086b259"];//设置您在mtj网站上添加的app的appkey,此处AppId即为应用的appKey
}
@end
