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
    //Realm数据库配置
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    //上线前记得增加数字 versin版本号增加
    config.schemaVersion = 9;
    //这个属性必须设置成NO YES过后会出错，数据库会被莫名删除
//    config.deleteRealmIfMigrationNeeded = YES;
    [RLMRealmConfiguration setDefaultConfiguration:config];
    //键盘遮挡问题解决方案
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    //初始化融云 只需要在程序启动时初始化一次 不然会有警告
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    //设置红包扩展的Url Schem
    [[RCIM sharedRCIM] setScheme:@"BangBang" forExtensionModule:@"JrmfPacketManager"];
    //百度统计
    [self startBDMobStat];
    //阿里热修复
//    [self startAliHotFix];
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
//    [AliHotFix sync];
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
//统一这个方法处理
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    //toady扩展
    if([[url.absoluteString componentsSeparatedByString:@"//"][1] isEqualToString:@"openCalendar"]) {
        //发出通知  统一在MainBusinessController处理
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormToday_openCalendar_Notication" object:[url.absoluteString componentsSeparatedByString:@"//"][2]];
    }
    //toady扩展
    if ([[url.absoluteString componentsSeparatedByString:@"//"][1] isEqualToString:@"addCalendar"]) {
        //发出通知  统一在MainBusinessController处理
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenSoft_FormToday_addCalendar_Notication" object:nil];
    }
    return [TencentOAuth HandleOpenURL:url] || [WXApi handleOpenURL:url delegate:self] || [WeiboSDK handleOpenURL:url delegate:self] || [[RCIM sharedRCIM] openExtensionModuleUrl:url];
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
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error  {
    
}
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
//启动阿里热修复
- (void)startAliHotFix {
//    char aesEncryptKeyBytes[] = {18,80,-105,120,16,79,75,-23,100,58,-3,74,117,-74,-49,5};
//    NSData *aesEncryptKeyData = [NSData dataWithBytes:aesEncryptKeyBytes length:sizeof(aesEncryptKeyBytes)];
//    char rsaPublicDerBytes[]={48,-126,2,1,48,-126,1,106,2,9,0,-32,77,107,-16,38,32,-88,95,48,13,6,9,42,-122,72,-122,-9,13,1,1,5,5,0,48,69,49,11,48,9,6,3,85,4,6,19,2,65,85,49,19,48,17,6,3,85,4,8,19,10,83,111,109,101,45,83,116,97,116,101,49,33,48,31,6,3,85,4,10,19,24,73,110,116,101,114,110,101,116,32,87,105,100,103,105,116,115,32,80,116,121,32,76,116,100,48,30,23,13,49,55,48,49,49,49,49,49,48,54,52,54,90,23,13,50,55,48,49,48,57,49,49,48,54,52,54,90,48,69,49,11,48,9,6,3,85,4,6,19,2,65,85,49,19,48,17,6,3,85,4,8,19,10,83,111,109,101,45,83,116,97,116,101,49,33,48,31,6,3,85,4,10,19,24,73,110,116,101,114,110,101,116,32,87,105,100,103,105,116,115,32,80,116,121,32,76,116,100,48,-127,-97,48,13,6,9,42,-122,72,-122,-9,13,1,1,1,5,0,3,-127,-115,0,48,-127,-119,2,-127,-127,0,-54,-106,-120,-33,18,-89,-44,5,-59,-50,-102,76,89,-83,88,15,-38,-99,19,96,-112,34,33,33,-76,-29,90,-62,-123,116,101,-57,-101,87,-43,-117,-55,94,46,-4,96,-124,-3,23,-10,-91,93,-124,58,-43,-95,123,-113,125,104,84,-99,82,-46,98,-70,118,49,42,124,-96,-79,-31,111,-39,-22,104,-92,-60,-40,83,78,59,-18,-86,-53,-97,104,63,-67,-108,41,104,77,107,61,37,5,-9,56,-40,121,-3,-92,54,-100,-120,-4,-74,-107,-20,-105,-91,41,-26,24,-56,115,-71,108,-15,-112,-12,-78,-124,79,-85,-46,58,-71,86,-80,113,2,3,1,0,1,48,13,6,9,42,-122,72,-122,-9,13,1,1,5,5,0,3,-127,-127,0,53,16,-96,-65,85,-38,21,-86,-30,-24,-76,29,58,123,-94,51,89,-31,-9,-5,-17,122,-69,-43,122,-127,-89,24,-93,-29,89,-64,38,111,-101,89,12,21,-122,-42,111,61,-123,-67,102,2,-121,-59,69,82,-20,-33,16,0,103,-38,54,58,10,100,-51,-37,34,101,-84,108,-117,-73,-80,35,18,1,-116,94,-63,52,-32,71,-125,-20,82,-55,41,61,-61,115,92,-54,54,-80,71,43,-87,5,104,102,-70,-69,-65,60,-19,94,17,3,-81,-103,-1,39,-74,-45,45,127,24,-44,-115,27,3,74,-10,124,-7,-123,-94,21,104,126,71,-75};
//    NSData *rsaPublicDerData = [NSData dataWithBytes:rsaPublicDerBytes length:sizeof(rsaPublicDerBytes)];
//    [AliHotFix startWithAppID:@"37332-2" secret:@"e4caef9cb0437c6597f9dcee99d568a2" privateKey:@"MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCIp8RFhU77tgb8wi5R3+c+/4HZH2h+eey6yf1i7NJ+0968RLfsDqpbqppZorhCBov/QqL0tkXL3VQ/oK6bnNbNuMBMsyF+wzEpX/j6WNFMRYpTFNt+3wmBKOghG61dWyMl/bHNkzCulZA6EX0FrVN1rfXT6yQ9OUJ7c5N41wpo6EI+0GHuoFhPhO3h8pjG3XKgqgLLht9CUzx286CkZ8Lh1xkueNtkm52rsb+Nxtez+3ldV+PJhUkSPTyiSdOtfScyGuqbHsJDcC7OtfqfX2hsQIZhN1uC0q/gi+eDuSgk5Gwh3ki9oGyF3UHSmvph6lvAra4MoAsG6rI8ANJvZiR5AgMBAAECggEAHndgr6snz8BmUGWuU/yaHpZySYjSEBh4qbAsuKhZyYLMzqZ3Zr5iRquDW+aGM9onzhH6KJqWdvvyM3lMVE8kKJs+7Bqnpg44YKQP6yhwCRQb4aftw5xQDyaikfcMsJqH/IlR4aYmHVYk4H1TpTdeOwc8njF3U9r3MnSy9SbkID0MBQsageyQ1FHhzJaUb1RCg4RapQrn1WK09sbGQeQxSliAbgGyXpnerzKsJHhcfwmXIboj2F+HSUigzC7BEKrJ6v2lgPRGFTX6SMOPTcRxpCRdU2IaURiv0DnnJ4TU8NRZczg7tqyn9z3grB6g3t29ybM+s6C+tnJsv3XlahivbQKBgQDMcTNO64FS6ce1QuQIXsyvqOaEZNrlk0HixtdQk4n6qBdhZQngdKGeCCDg/g/b+eT/cLAIg+sIwf4AHh++aoHSQxv6OrALempxFULmI84D91IUrrjn1jxje/dNImMqWI7ejcriWCK0lM+Ddpn5DvL5mgaNo6N8Lzk9TBQALO8EqwKBgQCrHj5Gl/qL7Q8qPu4G8B8qqUoI99LxveGQd7/+Z/kcnXKBsML8ry32BMivetagfOKg5zgq1+6IjlfVotEJaPhO0pWYAe2H2vr99gpAGrdNANq5ibcIVjVSLSYb0X0FLjOgnSPEDE1v06f3IKwiJl1TsDo+aIprf84ipJLD7XOTawKBgFEs6Xh+njzzwm5AfxarvY5J/C25dgkN7W1EEp5V1sWGFLKBUeijpsB+7b8oYdewY7LhZaQb7SjvDhGx5FzRIXcBWoyC3P/RvY3lKUkEEnsUqqy3q4eyUwwVXt5rtwBLZX8MwfAZmr4lEDhc0UpJG0TsWYnH3dQjVBD4skBXlxg9AoGAezYSl1gVMq2l7sBTObGqb1hoE58GR8R2Z0SifPe2mpEQAywYqkMk7/Ev45KqefKSaFM00Tyb572+pvhOVd08dd0Rk9tHgjv93+FKLjBObebAlzn/DcStLheOSheEUreauvqK5z4IgA3B8qKW7xv6tSi+N3Okv5TOA4nGl8chIjMCgYBbAWaFRLeSLibrurGnX2dD7S4AayEosH9UJ8Sx7Z2Rpuw3R34C7h7NQW17OnSJ76hGgr6ehsfic123rRzWF9VjXR4/H614dsFDOMHISsGw99daTikpnDUdhZAJ8AxkDVnlQSClJPcjRHAGL/WPkUF+ZCEh4DUUjRqxRBxgekoR7w==" publicKey:rsaPublicDerData encryptAESKey:aesEncryptKeyData];
//    // patchDirectory 为本地Patch目录全路径,注意该Patch目录结构参照'Part2生成patch补丁'中的Patch目录结构规则
////    NSString *mainPath = [NSBundle mainBundle].bundlePath;
////    [AliHotFixDebug runPatch:mainPath];
}

@end
