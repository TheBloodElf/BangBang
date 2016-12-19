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
#import "UserManager.h"

@interface AppDelegate ()<CLLocationManagerDelegate,WeiboSDKDelegate,WXApiDelegate> {
    CLLocationManager *_locationManager;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Realm数据库版本 数据模型改变 上线前记得数字增加
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 5;
    [RLMRealmConfiguration setDefaultConfiguration:config];
    //键盘遮挡问题解决方案
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    //初始化融云 只需要在程序启动时初始化一次 不然会有警告
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    //百度统计
    [self startBDMobStat];
    //注册微信APPID
    [WXApi registerApp:@"wxbd349c9a6abf20f8" withDescription:@"weixin"];
    //注册微博APPKEY
    [WeiboSDK registerApp:@"3837588781"];
    //Bugtags初始化
    [Bugtags startWithAppKey:BUGTAGSAPPKEY invocationEvent:BugOpen];
    //高德地图注册
    [AMapServices sharedServices].apiKey = @"812f92db9078841bddb73919f07e8d15";
    //高德地图适配https
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    //对应用进行全局的初始化
    [AppCustoms customs];
    //要求在使用时获取定位权限 把_locationManager是防止用户还没有点击确定，提示框就消失的问题
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    [_locationManager requestWhenInUseAuthorization];
    //创建根视图控制器
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //初始化时带上启动参数
    //在应用没有启动 点击其他部分激活应用在启动参数中是有相应内容的
    self.window.rootViewController = [[MainViewController alloc] initWithOptions:launchOptions];
    [self.window makeKeyAndVisible];
    //注册远程推送
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    //注册3d touch功能  只在6s上面使用（本人手机是6s，方便了自己）
    [self start3DTouch:launchOptions];
    //重定向log到本地文件 然后通过itunes打开 在应用列表下面的文件共享即可看到
    //需要在info.plist中打开 Application supports iTunes file sharing
    //上线时要去掉此字段 不然要被拒
//    if (![[[UIDevice currentDevice] model] isEqualToString:@"iPhone Simulator"]) {
//        [self redirectNSlogToDocumentFolder];
//    }
//    NSMutableArray *array = [@[@"2",@"2",@"2",@"3",@"4",@"5"] mutableCopy];
//    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//       if([obj isEqualToString:@"2"])
//           [array removeObject:obj];
//    }];
    return YES;
}
//- (void)redirectNSlogToDocumentFolder {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                         NSUserDomainMask, YES);
//    NSString *documentDirectory = [paths objectAtIndex:0];
//    
//    NSDate *currentDate = [NSDate date];
//    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
//    [dateformatter setDateFormat:@"MMddHHmmss"];
//    NSString *formattedDate = [dateformatter stringFromDate:currentDate];
//    
//    NSString *fileName = [NSString stringWithFormat:@"rc%@.log", formattedDate];
//    NSString *logFilePath =
//    [documentDirectory stringByAppendingPathComponent:fileName];
//    
//    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+",
//            stdout);
//    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+",
//            stderr);
//}
//进入应用
- (void)applicationDidBecomeActive:(UIApplication *)application {
    //清空应用红点
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if([UserManager manager].user.user_no == 0) return;
    //更新一下消息中心消息内容，手动创建一个模拟数据添加然后删除
    //触发一下数据库的回调
    PushMessage *pushMessage = [PushMessage new];
    pushMessage.id = @(1).stringValue;
    [[UserManager manager] addPushMessage:pushMessage];
    [[UserManager manager] deletePushMessage:pushMessage];
}
//退出应用
//- (void)applicationWillResignActive:(UIApplication *)application {

//}
//3d touch入口
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    //获取点击标示 分别进行操作
    int currIndex = 0;
    if ([shortcutItem.type isEqualToString:@"今日日程"]) {
        currIndex = 0;
    } else if ([shortcutItem.type isEqualToString:@"签到"]) {
        currIndex = 1;
    }
    //发出通知  统一在MainBusinessController处理
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormTouch_Notication" object:@(currIndex)];
    completionHandler(YES);
}
//Spotlight进来的
//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
//    if ([[userActivity activityType] isEqualToString:CSSearchableItemActionType]) {
//        NSString *uniqueIdentifier = [userActivity.userInfo objectForKey:CSSearchableItemActivityIdentifier];
//        //uniqueIdentifier可以是"calendar:2020"，表示传过来的是日程，日程ID为2020，然后查看详情
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormSpotlight_Notication" object:uniqueIdentifier];
//    }
//    return YES;
//}
//today扩展进来的 qq分享进入qq应用分享界面是用open方法通过这个回调实现的
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    if([[url.absoluteString componentsSeparatedByString:@"//"][1] isEqualToString:@"openCalendar"]) {
        //发出通知  统一在MainBusinessController处理
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormToday_openCalendar_Notication" object:[url.absoluteString componentsSeparatedByString:@"//"][2]];
    } else if ([[url.absoluteString componentsSeparatedByString:@"//"][1] isEqualToString:@"addCalendar"]) {
        //发出通知  统一在MainBusinessController处理
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormToday_addCalendar_Notication" object:nil];
    }
    return [TencentOAuth HandleOpenURL:url] || [WXApi handleOpenURL:url delegate:self] || [WeiboSDK handleOpenURL:url delegate:self];
}
#pragma mark - WBApiDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}
-(void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        WBAuthorizeResponse *authorizeResponse = (WBAuthorizeResponse *)response;
        //发出通知  在登陆页面处理微博登陆结果
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WBApiDelegate" object:authorizeResponse];
    }
}
#pragma mark - WXApiDelegate
-(void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        //发出通知  在登陆页面处理微信登陆结果
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WXApiDelegate" object:authResp];
    }
}
//获取token失败
//- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error  {
//    
//}
//收到推送token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *currDeviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    //向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:currDeviceToken];
    //注册融云推送
    [[RCIMClient sharedRCIMClient] setDeviceToken:currDeviceToken];
    //保存deviceToken在本地
    [IdentityManager manager].identity.deviceIDAPNS = currDeviceToken;
    [[IdentityManager manager] saveAuthorizeData];
}
//后台刷新数据
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /// Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}
//收到本地推送 上下班、任务提醒等本地推送
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification  {
    //交给管理器去处理
    if([UserManager manager].user.canPlayVoice) {//声音
        // 1.创建SystemSoundID,根据音效文件来生成
        SystemSoundID soundID = 0;
        // 2.根据音效文件,来生成SystemSoundID
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"notification_ring.mp3" withExtension:nil];
        CFURLRef urlRef = (__bridge CFURLRef)(url);
        AudioServicesCreateSystemSoundID(urlRef, &soundID);
        // 播放音效
        AudioServicesPlaySystemSound(soundID);
    }
    if([UserManager manager].user.canPlayShake)//震动
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    //更新一下消息内容，手动创建一个数据添加然后删除
    //触发一下数据库的回调
    PushMessage *pushMessage = [PushMessage new];
    pushMessage.id = @(1).stringValue;
    [[UserManager manager] addPushMessage:pushMessage];
    [[UserManager manager] deletePushMessage:pushMessage];
}
//点击本地推送的action触发
//- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler {
//    
//}
//收到远程推送
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    
//}
//点击远程推送的action触发
//- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler {
//
//}
//注册3D TOUCH
- (void)start3DTouch:(NSDictionary *)launchOptions {
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f) {
        UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKeyedSubscript:UIApplicationLaunchOptionsShortcutItemKey];
        int currIndex = [shortcutItem.type isEqualToString:@"今日日程"] ? 0 : 1;
        //发出通知弹出控制器 统一在MainBusinessController处理
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormTouch_Notication" object:@(currIndex)];
    }
}
//注册百度统计
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
