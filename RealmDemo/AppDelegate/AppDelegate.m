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
    config.schemaVersion = 11;
    [RLMRealmConfiguration setDefaultConfiguration:config];
    //百度统计
    [self startBDMobStat];
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
    return YES;
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
//因为有个推，所以这个函数不用
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
//    
//}
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
