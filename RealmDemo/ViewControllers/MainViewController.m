//
//  MainViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MainViewController.h"
#import "IdentityManager.h"
#import "UserManager.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "LoginController.h"
#import "WelcomeController.h"
#import "BusinessController.h"
//当前控制器管理业务、登陆和欢迎界面
//并且同一时间只存在三个中的一个，并通过addChildViewController加入
//登陆、欢迎和业务三个之间的切换通过发送通知到本控制器来处理
@interface MainViewController ()<RCIMUserInfoDataSource,RCIMGroupInfoDataSource,RCIMConnectionStatusDelegate,GeTuiSdkDelegate> {
    WelcomeController *_welcome;//欢迎界面
    LoginController *_login;//登录界面
    BusinessController *_business;//业务界面
    NSUserDefaults * defaults;//用户偏好设置
}
@property (nonatomic, strong) NSDictionary *launchOptions;

@end

@implementation MainViewController

- (instancetype)initWithOptions:(NSDictionary *)launchOptions {
    self = [super init];
    if(self) {
        _launchOptions = launchOptions;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    defaults = [NSUserDefaults standardUserDefaults];
    //从本地读取登录信息
    IdentityManager *manager = [IdentityManager manager];
    [manager readAuthorizeData];
    //保存当前的版本号
    manager.identity.lastSoftVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [manager saveAuthorizeData];
    [self gotoIdentityVC];
    //初始化融云
    [[RCIM sharedRCIM] setUserInfoDataSource:self];
    [[RCIM sharedRCIM] setGroupInfoDataSource:self];
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(43, 43);
    [RCIM sharedRCIM].connectionStatusDelegate = self;
    //加上重新登录的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogin:) name:@"ShowLogin" object:nil];
    //加上欢迎界面结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(welcomeDidFinish) name:@"WelcomeDidFinish" object:nil];
    //加上登录界面结束的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidFinish) name:@"LoginDidFinish" object:nil];
}
//弹出登录控制器
- (void)showLogin:(NSNotification*)noti{
    //是否不需要弹窗
    //被融云挤下线需要提示 但是用户在设置界面点击退出登陆不需要弹出提示
    if([NSString isBlank:noti.object]) {
        [self gotoIdentityVC];
        return;
    }
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:noti.object message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self gotoIdentityVC];
    }];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//欢迎界面展示完毕
- (void)welcomeDidFinish {
    //设置登录信息的firstUseSoft值
    IdentityManager *manager = [IdentityManager manager];
    manager.identity.firstUseSoft = NO;
    [manager saveAuthorizeData];
    //进入判断逻辑
    [self gotoIdentityVC];
}
//登录界面展示完毕
- (void)loginDidFinish {
    //进入判断逻辑
    [self gotoIdentityVC];
}
//进入判断逻辑
- (void)gotoIdentityVC {
    IdentityManager *identityManager = [IdentityManager manager];
    //需不需要迁移数据 因为旧版本是用的WelcomeViewReadssss来保存版本号
    //所有如果用户偏好设置有WelcomeViewReadssss这个key就说明需要迁移
    if([defaults.dictionaryRepresentation.allKeys containsObject:@"WelcomeViewReadssss"]) {
        //添加一个背景
        [self addBGMView];
        [self.navigationController.view showLoadingTips:@"迁移数据..."];
        //用FMDB来获取旧的数据 这里要注意了
        //因为旧版本的数据库用的fmdb，所以这里我们同步的思路如下
        //1:获取数据库文件路径
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"ReSearch.db"];
        //2:加载数据库并打开
        FMDatabase *fMDatabase = [FMDatabase databaseWithPath:writableDBPath];
        [fMDatabase open];
        //3:是否存在登录用户
        //如果存在就同步 如果没有就不同步了直接重新登录
        NSData* data = [defaults objectForKey:@"BangBangUserInfo"];
        if(!data) {
            [defaults removeObjectForKey:@"WelcomeViewReadssss"];
            [self.view dismissTips];
            [self remBGMView];
            [self gotoIdentityVC];
            return;
        }
        //#148
        //旧版本是用用户偏好设置BangBangAccessToken保存accessToken
        identityManager.identity.accessToken = [defaults objectForKey:@"BangBangAccessToken"] ? : @"";
        //4:读取出用户信息
        NSDictionary *userDic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        User *user = [User new];
        [user mj_setKeyValues:userDic];
        //旧版本是用用户偏好设置RongYunToken保存融云token的
        user.RYToken = [defaults objectForKey:@"RongYunToken"];
        UserManager *userManager = [UserManager manager];
        //5:在新版本中创建该用户的数据库 开始获取必要的信息
        [userManager loadUserWithGuid:user.user_guid];
        [userManager updateUser:user];
        //6:同步日程
        FMResultSet *calendarResultSet = [fMDatabase executeQuery:@"select * from tb_Calendar"];
        while (calendarResultSet.next) {
            @synchronized (self) {//必须原子操作
                //要把这个日程放到哪个用户文件
                NSString *currentUser = [calendarResultSet stringForColumn:@"currentUser"];
                [userManager loadUserWithGuid:currentUser];
                Calendar *calendar = [Calendar new];
                calendar.id = [calendarResultSet stringForColumn:@"id"].intValue;
                calendar.company_no = [calendarResultSet stringForColumn:@"company_no"].intValue;
                calendar.event_name = [calendarResultSet stringForColumn:@"event_name"];
                calendar.descriptionStr = [calendarResultSet stringForColumn:@"description"];
                calendar.address = [calendarResultSet stringForColumn:@"address"];
                calendar.begindate_utc = [calendarResultSet doubleForColumn:@"begindate_utc"];
                calendar.enddate_utc = [calendarResultSet doubleForColumn:@"enddate_utc"];
                calendar.is_allday = [calendarResultSet boolForColumn:@"is_allday"];
                calendar.app_guid = [calendarResultSet stringForColumn:@"app_guid"];
                calendar.target_id = [calendarResultSet stringForColumn:@"article_id"];
                calendar.repeat_type = [calendarResultSet intForColumn:@"repeat_type"];
                calendar.is_alert = [calendarResultSet boolForColumn:@"is_alert"];
                calendar.alert_minutes_before = [calendarResultSet stringForColumn:@"alert_minutes_before"].intValue;
                calendar.alert_minutes_after = [calendarResultSet stringForColumn:@"alert_minutes_after"].intValue;
                calendar.user_guid = [calendarResultSet stringForColumn:@"user_guid"];
                calendar.created_by = [calendarResultSet stringForColumn:@"created_by"];
                calendar.createdon_utc = [calendarResultSet stringForColumn:@"createdon_utc"].doubleValue;
                calendar.updated_by = [calendarResultSet stringForColumn:@"updated_by"];
                calendar.updatedon_utc = [calendarResultSet stringForColumn:@"updatedon_utc"].doubleValue;
                calendar.status = [calendarResultSet intForColumn:@"status"];
                calendar.finishedon_utc = [calendarResultSet stringForColumn:@"finishedon_utc"].doubleValue;
                calendar.rrule = [calendarResultSet stringForColumn:@"rrule"];
                calendar.emergency_status = [calendarResultSet intForColumn:@"emergency_status"];
                calendar.deleted_dates = [calendarResultSet stringForColumn:@"deleted_dates"];
                calendar.finished_dates = [calendarResultSet stringForColumn:@"finished_dates"];
                calendar.r_begin_date_utc = [calendarResultSet doubleForColumn:@"r_begin_date_utc"];
                calendar.r_end_date_utc = [calendarResultSet doubleForColumn:@"r_end_date_utc"];
                calendar.is_over_day = [calendarResultSet boolForColumn:@"is_over_day"];
                calendar.members = [calendarResultSet stringForColumn:@"members"];
                calendar.member_names = [calendarResultSet stringForColumn:@"member_names"];
                calendar.event_guid = [calendarResultSet stringForColumn:@"event_guid"];
                calendar.creator_name = [calendarResultSet stringForColumn:@"creator_name"];
                [userManager addCalendar:calendar];
            }
        }
        //7:同步讨论组
        FMResultSet *userDiscussResultSet = [fMDatabase executeQuery:@"select * from tb_UserDiscuss"];
        while (userDiscussResultSet.next) {
            @synchronized (self) {//必须原子操作
                //要把这个任务放到哪个用户文件
                NSString *currentUser = [userDiscussResultSet stringForColumn:@"currentUser"];
                [userManager loadUserWithGuid:currentUser];
                UserDiscuss *userDiscuss = [UserDiscuss new];
                userDiscuss.id = [userDiscussResultSet stringForColumn:@"id"].intValue;
                userDiscuss.user_no = [userDiscussResultSet stringForColumn:@"user_no"].intValue;
                userDiscuss.user_guid = [userDiscussResultSet stringForColumn:@"user_guid"];
                userDiscuss.discuss_id = [userDiscussResultSet stringForColumn:@"discuss_id"];
                userDiscuss.discuss_title = [userDiscussResultSet stringForColumn:@"discuss_title"];
                userDiscuss.createdon_utc = [userDiscussResultSet doubleForColumn:@"createdon_utc"];
                [userManager addUserDiscuss:userDiscuss];
            }
        }
        //8:消息中心
        FMResultSet *fMResultSet = [fMDatabase executeQuery:@"select * from tb_PushMessage"];
        int index = 1000;
        while (fMResultSet.next) {
            @synchronized (self) {//必须原子操作
                //只插入给自己的 旧数据库是根据这个来辨别推送消息属于谁的
                int toUserNo = [fMResultSet stringForColumn:@"to_user_no"].intValue;
                if(toUserNo != user.user_no) continue;
                PushMessage *pushMessage = [PushMessage new];
                pushMessage.id = @(index++).stringValue;
                pushMessage.target_id = [fMResultSet stringForColumn:@"target_id"];
                pushMessage.type = [fMResultSet stringForColumn:@"type"];
                pushMessage.content = [fMResultSet stringForColumn:@"content"];
                pushMessage.icon = [fMResultSet stringForColumn:@"icon"];
                pushMessage.addTime = [NSDate dateWithTimeIntervalSince1970:[fMResultSet stringForColumn:@"time"].doubleValue / 1000];
                pushMessage.company_no = [fMResultSet stringForColumn:@"company_no"].intValue;
                pushMessage.from_user_no = [fMResultSet stringForColumn:@"from_user_no"].intValue;
                pushMessage.to_user_no = [fMResultSet stringForColumn:@"to_user_no"].intValue;
                pushMessage.unread = [fMResultSet boolForColumn:@"unread"];
                pushMessage.action = [fMResultSet stringForColumn:@"action"];
                pushMessage.entity = [fMResultSet stringForColumn:@"entity"];
                [userManager addPushMessage:pushMessage];
            }
        }
        //9:同步完成，继续登陆逻辑
        identityManager.identity.user_guid = user.user_guid;
        identityManager.identity.firstUseSoft = NO;
        [identityManager saveAuthorizeData];
        //清除旧版本标识符，此后该手机不再需要同步旧数据
        [defaults removeObjectForKey:@"WelcomeViewReadssss"];
        [self remBGMView];
        [self.navigationController.view dismissTips];
        [self gotoIdentityVC];
        return;
    }
    //看用户是不是第一次使用软件
    if(identityManager.identity.firstUseSoft == 1) {
        _welcome = [WelcomeController new];
        _welcome.view.alpha = 0;
        [_welcome willMoveToParentViewController:self];
        [_welcome.view willMoveToSuperview:self.view];
        [self addChildViewController:_welcome];
        [self.view addSubview:_welcome.view];
        //如果是从业务界面进来 (后面想了一下好像不可能有这种情况)
        if([self.childViewControllers containsObject:_business]) {
            //进行动画切换
            [self transitionFromViewController:_business toViewController:_welcome duration:1 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut animations:^{
                _welcome.view.alpha = 1;
                _business.view.alpha = 0;
            } completion:^(BOOL finished) {
                [_business.view removeFromSuperview];
                [_business removeFromParentViewController];
            }];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                _welcome.view.alpha = 1;
            }];
        }
        return;
    }
    //看用户是否登录
    if([NSString isBlank:identityManager.identity.user_guid]) {
        _login = [LoginController new];
        //#BANG-390 三方登录崩溃问题
        //原来写成了：_login.view = 0;应该是下面
        _login.view.alpha = 0;
        [_login willMoveToParentViewController:self];
        [_login.view willMoveToSuperview:self.view];
        [self addChildViewController:_login];
        [self.view addSubview:_login.view];
        //如果是从欢迎界面进来（第一次使用软件会进入欢迎界面，然后点击跳过）
        if([self.childViewControllers containsObject:_welcome]) {
            [self transitionFromViewController:_welcome toViewController:_login duration:1 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut animations:^{
                _login.view.alpha = 1;
                _welcome.view.alpha = 0;
            } completion:^(BOOL finished) {
                [_welcome.view removeFromSuperview];
                [_welcome removeFromParentViewController];
            }];
        } else if([self.childViewControllers containsObject:_business]){//如果是从业务界面进来（用户在设置界面点击退出登陆）
            [self transitionFromViewController:_business toViewController:_login duration:1 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut animations:^{
                _login.view.alpha = 1;
                _business.view.alpha = 0;
            } completion:^(BOOL finished) {
                [_business.view removeFromSuperview];
                [_business removeFromParentViewController];
            }];
        } else {
            [UIView animateWithDuration:0.5 animations:^{
                _login.view.alpha = 1;
            }];
        }
        return;
    }
    //加载已经登陆的用户数据库
    [[UserManager manager] loadUserWithGuid:identityManager.identity.user_guid];
    //初始化个推
    [GeTuiSdk startSdkWithAppId:kAppId appKey:kAppKey appSecret:kAppSecret delegate:self];
    //连接融云
    [[RCIM sharedRCIM] connectWithToken:[UserManager manager].user.RYToken success:^(NSString *userId){}error:^(RCConnectErrorCode status){}tokenIncorrect:^(){}];
    //加载主页
    _business = [[BusinessController alloc] initWithOptions:_launchOptions];
    _business.view.alpha = 0;
    [_business willMoveToParentViewController:self];
    [_business.view willMoveToSuperview:self.view];
    [self addChildViewController:_business];
    [self.view addSubview:_business.view];
    _launchOptions = nil;
    //如果是从登录界面进来（登陆完成跳转到此）
    if([self.childViewControllers containsObject:_login]) {
        [self transitionFromViewController:_login toViewController:_business duration:1 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut animations:^{
            _business.view.alpha = 1;
            _login.view.alpha = 0;
        } completion:^(BOOL finished) {
            [_login removeFromParentViewController];
            [_login.view removeFromSuperview];
        }];
    } else {
        [UIView animateWithDuration:0.5 animations:^{
           _business.view.alpha = 1;
        }];
    }
}
#pragma mark -- 个推代理
//初始化个推会走这个回调
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    [GeTuiSdk bindAlias:@([UserManager manager].user.user_no).stringValue andSequenceNum:@""];
    [UserHttp setupAPNSDevice:clientId userNo:[UserManager manager].user.user_no handler:^(id data, MError *error) {}];
}
//收到个推推送会回调此处
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    //发出通知  统一在MainBusinessController处理
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecivePushMessage" object:payloadData];
}
#pragma mark -- 融云代理
- (void)getGroupInfoWithGroupId:(NSString*)groupId completion:(void (^)(RCGroup*))completion
{
    //根据组id获取圈子信息
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<Company*> *companyArr = [[UserManager manager] getCompanyArr];
        RCGroup * group = [[RCGroup alloc]init];
        for (Company *company in companyArr) {
            if(company.company_no == [groupId intValue]) {
                group.groupId = groupId;
                group.groupName = company.company_name;
                group.portraitUri = company.logo;
                break;
            }
        }
        completion(group);
    });
}
- (void)getUserInfoWithUserId:(NSString*)userId completion:(void (^)(RCUserInfo*))completion
{
    //根据user_no获取员工信息
    dispatch_async(dispatch_get_main_queue(), ^{
        UserManager *manager = [UserManager manager];
        NSMutableArray *array = [manager getEmployeeArr];
        Employee * emp = [Employee new];
        for (Employee *employee in array) {
            if(employee.user_no == [userId integerValue]) {
                emp = employee;
                break;
            }
        }
        RCUserInfo * user = [[RCUserInfo alloc] init];
        user.userId = userId;
        user.name = emp.user_real_name;
        user.portraitUri = emp.avatar;
        completion(user);
    });
}
//融云连接状态发生改变走此回调，只需要处理该用户在
//其他设备登陆状态即可
-(void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
    NSString *result = nil;
    switch (status) {
        case -1:result = @"未知状态。";break;
        case 0:result = @"连接成功。";break;
        case 1:result = @"网络连接不可用。";break;
        case 2: result = @"设备处于飞行模式。";break;
        case 3:result = @"设备处于2G低网速下。";break;
        case 4:result = @"设备处于3G,4G网速下。";break;
        case 5: result = @"设备切换到WIFI网络下。";break;
        case 6:result = @"设备在其它设备登陆。";break;
        case 12:result = @"注销";break;
        case 31004:result = @"Token无效，可能是token错误，token过期或者后台刷新了密钥等原因。";break;
        case 31011:result = @"服务器断开连接。";break;
        default:result = @"其他状态。";break;
    }
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        [[IdentityManager manager] logOut];
        [[IdentityManager manager] showLogin:@"你的账号在其他设备上登录，请重新登录"];
    }
}
//添加迁移数据的背景图
- (void)addBGMView {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    imageView.image = [UIImage imageNamed:@"lauch_screen_background"];
    imageView.tag = 10001;
    [self.view addSubview:imageView];
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_screen_icon"]];
    topImageView.frame = CGRectMake(0.5 * (MAIN_SCREEN_WIDTH - topImageView.frame.size.width), 50, topImageView.frame.size.width, topImageView.frame.size.height);
    topImageView.tag = 10002;
    [imageView addSubview:topImageView];
    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 118, MAIN_SCREEN_WIDTH, 18)];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.text = @"帮帮，为执行力而生";
    bottomLabel.textColor = [UIColor whiteColor];
    bottomLabel.font = [UIFont systemFontOfSize:15];
    bottomLabel.tag = 10003;
    [imageView addSubview:bottomLabel];
}
//添加迁移数据的背景图
- (void)remBGMView {
    [[self.view viewWithTag:10001] removeFromSuperview];
    [[self.view viewWithTag:10002] removeFromSuperview];
    [[self.view viewWithTag:10003] removeFromSuperview];
}

@end
