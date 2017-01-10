//
//  TabBarController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MainBusinessController.h"
#import "HomeListController.h"
#import "MessageController.h"
#import "XAddrBookController.h"
#import "MineViewController.h"
#import "MoreSelectController.h"
#import "WebNonstandarViewController.h"
#import "UserManager.h"
#import "IdentityManager.h"
#import "CalendarCreateController.h"
#import "TaskCreateController.h"
#import "CreateMeetingController.h"
#import "UserHttp.h"
#import "TaskDetailController.h"
#import "CreateSiginController.h"
#import "CalendarController.h"
#import "ComCalendarDetailViewController.h"
#import "RepCalendarDetailController.h"
#import "BindPhoneController.h"

@interface MainBusinessController ()<UITabBarControllerDelegate,MoreViewControllerDelegate,BindPhoneDelegate> {
    UITabBarController *_tabBarVC;
    UserManager *_userManager;
    IdentityManager *_identityManager;
    NSMutableArray *_needSyncCalender;//需要同步的日程
}
@property (nonatomic, strong) NSDictionary *launchOptions;

@end

@implementation MainBusinessController

- (instancetype)initWithOptions:(NSDictionary *)launchOptions {
    self = [super init];
    if(self) {
        _launchOptions = launchOptions;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    _identityManager = [IdentityManager manager];
    //创建界面
    _tabBarVC = [UITabBarController new];
    _tabBarVC.viewControllers = @[[self homeListController],[self messageController],[self centerController],[self xAddrBookController],[self mineViewController]];
    _tabBarVC.delegate = self;
    [self addChildViewController:_tabBarVC];
    [self.view addSubview:_tabBarVC.view];
    //加上3d touch进入应用的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveTouch:) name:@"OpenSoft_FormTouch_Notication" object:nil];
    //加上个推消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecivePushMessage:) name:@"DidRecivePushMessage" object:nil];
    //加上从today进来的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveAddToday:) name:@"OpenSoft_FormToday_addCalendar_Notication" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveOpenToday:) name:@"OpenSoft_FormToday_openCalendar_Notication" object:nil];
    //添加spotlight索引
//    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f) {
//        [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {}];
//        [self insertSearchableItem:UIImagePNGRepresentation([UIImage imageNamed:@"default_image_icon"]) spotlightTitle:@"帮帮管理助手" description:@"身边不可获取的办公软件" keywords:@[@"日程",@"任务",@"会议",@"签到"] spotlightInfo:@"OpenSoft" domainId:@"com.lottak.BangBang"];
//    }
    //加上spotlight进来的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveOpenSpotlight:) name:@"OpenSoft_FormSpotlight_Notication" object:nil];
    //查看当前用户是否绑定了手机号
    [self checkUserPhone];
    //检查启动参数 如果有就进行相应的跳转
    //后面想了一下，本地推送已经存入数据库 远程推送有个推的透传，可以不需要检查启动参数了
//    [self checkOption];
    //检查网络是否连接
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //这里进程序就会回调一次 所以可以在这里进行程序进入后加载所需要的最新数据 进入时加载必要的最新数据
        if(status == -1 || status == 0) {
            [self.navigationController.view showFailureTips:@"网络不可用，请连接网络"];
            return;
        }
        if(!_userManager.user.currCompany.company_no) return;
        [self getCompanySiginRule];//获取签到规则 这里第一次进入应用是获取不到签到规则的  因为第一次用户当前没有圈子 是在[self checkSyncCalender]中获取的    不过这里写上的作用在于网络可用时再获取一次
        [self checkSyncCalender];//同步日程
    }];
    //每次进来重新获取一次圈子和员工信息，保证数据的有效性
    [self requestCompanyEmployee];
}

- (void)requestCompanyEmployee {
    //获取所有圈子 所有状态员工
    [UserHttp getCompanysUserGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *companys = [@[] mutableCopy];
        for (NSDictionary *tempDic in data) {
            Company *company = [Company new];
            [company mj_setKeyValues:tempDic];
            [companys addObject:company];
        }
        [_userManager updateCompanyArr:companys];
        //获取所有圈子的员工信息
        [UserHttp getEmployeeCompnyNo:0 status:5 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController dismissTips];
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSMutableArray *array = [@[] mutableCopy];
            for (NSDictionary *dic in data[@"list"]) {
                Employee *employee = [Employee new];
                [employee mj_setKeyValues:dic];
                [array addObject:employee];
            }
            //#BANG-585 company_no传0获取不到状态为0的员工
            [UserHttp getEmployeeCompnyNo:0 status:0 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController dismissTips];
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                for (NSDictionary *dic in data[@"list"]) {
                    Employee *employee = [Employee new];
                    [employee mj_setKeyValues:dic];
                    [array addObject:employee];
                }
                [_userManager updateEmployee:array companyNo:0];
                //如果当前用户没有圈子，就重新给一个 把第一个正式员工作为自己当前圈子
                if(_userManager.user.currCompany.company_no != 0)
                    return;
                for (Company *company in [_userManager getCompanyArr]) {
                    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
                    if(employee.status == 1 || employee.status == 4) {
                        _userManager.user.currCompany = company;
                        break;
                    }
                }
                [_userManager updateUser:_userManager.user];
            }];
        }];
    }];
}
#pragma mark -- 检查启动参数 是否有本地推送 3dtouch 远程推送 today扩展
- (void)checkOption {
    if(!_launchOptions)
        return;
    //如果是通过openurl进来的（本工程只有today扩展响应是如此）
//    if([_launchOptions.allKeys[0] isEqualToString:UIApplicationLaunchOptionsURLKey]) {
//        NSString *value = [_launchOptions.allValues[0] absoluteString];
//        //是不是日程操作
//        if([value rangeOfString:@"Calendar"].location != NSNotFound) {
//            //是不是查看日程
//            if([[value componentsSeparatedByString:@"//"][1] isEqualToString:@"openCalendar"]) {
//                int calendarId = [[value componentsSeparatedByString:@"//"][2] intValue];
//                for (Calendar *calendar in [_userManager getCalendarArr]) {
//                    //去掉删除的
//                    if(calendar.status == 0) continue;
//                    if(calendar.id == calendarId) {
//                        //展示详情
//                        if(calendar.repeat_type == 0) {
//                            Calendar *tempTemp = calendar;
//                            tempTemp.rdate = @([NSDate date].timeIntervalSince1970).stringValue;
//                            ComCalendarDetailViewController *vc = [ComCalendarDetailViewController new];
//                            vc.data = tempTemp;
//                            [self.navigationController pushViewController:vc animated:YES];
//                            
//                        } else {
//                            Calendar *tempTemp = calendar;
//                            tempTemp.rdate = @([NSDate date].timeIntervalSince1970).stringValue;
//                            RepCalendarDetailController *vc = [RepCalendarDetailController new];
//                            vc.data = tempTemp;
//                            [self.navigationController pushViewController:vc animated:YES];
//                        }
//                        break;
//                    }
//                }
//            } else if ([[value componentsSeparatedByString:@"//"][1] isEqualToString:@"addCalendar"]) {
//                //添加日程
//                [self.navigationController pushViewController:[CalendarCreateController new] animated:YES];
//            }
//        }
//    }
    //是不是本地推送 因为在appdelegate中的应用将要进入前台做了处理，所以这里就不需要做处理了
//    if([_launchOptions.allKeys[0] isEqualToString:UIApplicationLaunchOptionsLocalNotificationKey]) {
//        NSMutableDictionary *dictionary = [[_launchOptions.allValues[0] mj_keyValues] mutableCopy];
//        [dictionary setObject:@([NSDate date].timeIntervalSince1970 * 1000).stringValue forKey:@"id"];
//        PushMessage *pushMessage = [PushMessage new];
//        [pushMessage mj_setKeyValues:dictionary];
//        pushMessage.addTime = [NSDate date];
//        [[UserManager manager] addPushMessage:pushMessage];
//    }
    //是不是远程推送 本工程不做处理，以个推的透穿消息为准
    //    if([option.allKeys[0] isEqualToString:UIApplicationLaunchOptionsRemoteNotificationKey]) {
    //
    //    }
    //是不是3dtouch进来的
//    if([_launchOptions.allKeys[0] isEqualToString:UIApplicationLaunchOptionsShortcutItemKey]) {
//        UIApplicationShortcutItem *shortcutItem = _launchOptions.allValues[0];
//        int currIndex = [shortcutItem.type isEqualToString:@"今日日程"] ? 0 : 1;
//        if(currIndex == 0) {//今日日程
//            [self.navigationController pushViewController:[CalendarController new] animated:YES];
//        } else if (currIndex == 1) {//签到
//            [self executeNeedSelectCompany:^{
//                UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
//                CreateSiginController *sigin = [story instantiateViewControllerWithIdentifier:@"CreateSiginController"];
//                [self.navigationController pushViewController:sigin animated:YES];
//            }];
//        }
//    }
    //是不是spotlight进来的 这里暂时不用
    //    if([option.allKeys[0] isEqualToString:UIApplicationLaunchOptionsSourceApplicationKey]) {
    //
    //    }
}
//查看当前用户是否绑定了手机号
- (void)checkUserPhone {
    UserManager *userManager = [UserManager manager];
    //是否有手机号
    if(![NSString isBlank:userManager.user.mobile]) return;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
    BindPhoneController *bindPhone = [story instantiateViewControllerWithIdentifier:@"BindPhoneController"];
    bindPhone.delegate = self;
    bindPhone.providesPresentationContextTransitionStyle = YES;
    bindPhone.definesPresentationContext = YES;
    bindPhone.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self.navigationController presentViewController:bindPhone animated:NO completion:nil];
}
#pragma mark --
#pragma mark -- BindPhoneDelegate
- (void)bindPhoneClicked {
    UserManager *userManager = [UserManager manager];
    WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
    webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@/security/index?userGuid=%@&access_token=%@&companyNo=%d",XYFMobileDomain,userManager.user.user_guid,[IdentityManager manager].identity.accessToken,userManager.user.currCompany.company_no];
    [self.navigationController pushViewController:webViewcontroller animated:YES];
}
- (void)bindCancle {
    
}
#pragma mark --
#pragma mark -- 这里是需要有网就操作的
//获取签到规则
- (void)getCompanySiginRule {
    //没有圈子就不获取规则
    if(_userManager.user.currCompany.company_no == 0)
        return;
    [UserHttp getSiginRule:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *dic in data) {
            NSMutableDictionary *dicDic = [dic mutableCopy];
            dicDic[@"work_day"] = [dicDic[@"work_day"] componentsJoinedByString:@","];
            SiginRuleSet *set = [SiginRuleSet new];
            [set mj_setKeyValues:dicDic];
            //这里动态添加签到地址
            RLMArray<PunchCardAddressSetting> *settingArr = [[RLMArray<PunchCardAddressSetting> alloc] initWithObjectClassName:@"PunchCardAddressSetting"];
            for (NSDictionary *settingDic in dicDic[@"address_settings"]) {
                PunchCardAddressSetting *setting = [PunchCardAddressSetting new];
                [setting mj_setKeyValues:settingDic];
                [settingArr addObject:setting];
            }
            set.json_list_address_settings = settingArr;
            [array addObject:set];
        }
        [_userManager updateSiginRule:array companyNo:_userManager.user.currCompany.company_no];
    }];
}
//看有没有日程需要同步
- (void)checkSyncCalender {
    _needSyncCalender = [@[] mutableCopy];
    for (Calendar *calender in [_userManager getCalendarArr]) {
        //查看需要同步的日程
        if(calender.needSync == YES) {
            //这里要排除本地创建本地删除的
            if(calender.id < 0 && calender.status == 0) continue;
            [_needSyncCalender addObject:calender];
        }
    }
    if(!_needSyncCalender.count) return;
    [self.navigationController.view showLoadingTips:@"上传离线日程..."];
    [self syncCalender];
}
- (void)syncCalender {
    if(_needSyncCalender.count == 0) {
        [self.navigationController.view dismissTips];
        return;
    }
    Calendar *calendar = _needSyncCalender.firstObject;
    //网络创建的
    if(calendar.id > 0) {
        if(calendar.status == 0) {//删除日程
            [UserHttp deleteUserCalendar:calendar.id handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController.view dismissTips];
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                //更新本地的日程
                calendar.needSync = NO;
                [_userManager updateCalendar:calendar];
                [_needSyncCalender removeObjectAtIndex:0];
                [self syncCalender];
            }];
        } else {//同步日程
            NSString *members = calendar.members;
            calendar.members = @"";//要清除掉分享者，不然又会推送一条日程给分享者
            [UserHttp syncUserCalendar:calendar handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController.view dismissTips];
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                calendar.needSync = NO;
                calendar.members = members;
                [_userManager updateCalendar:calendar];
                [_needSyncCalender removeObjectAtIndex:0];
                [self syncCalender];
            }];
        }
    } else {//本地创建的
       //调用同步接口
        int64_t tempId = calendar.id;
        calendar.id = 0;
        [UserHttp syncUserCalendar:calendar handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view dismissTips];
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            //删除旧的日程
            calendar.status = 0;
            calendar.id = tempId;
            calendar.needSync = NO;
            [_userManager updateCalendar:calendar];
            //添加新建日程
            [calendar mj_setKeyValues:data];
            calendar.descriptionStr = data[@"description"];
            [_userManager addCalendar:calendar];
            [_needSyncCalender removeObjectAtIndex:0];
            [self syncCalender];
        }];
    }
}
#pragma mark -- 
#pragma mark -- Notification
//Spotlight进来的
//- (void)didReciveOpenSpotlight:(NSNotification*)notification {
    //    NSString *currStr = notification.object;
//}
//Today进来 添加日程
- (void)didReciveAddToday:(NSNotification*)notification {
    //添加日程
    [self.navigationController pushViewController:[CalendarCreateController new] animated:YES];
}
//Today进来 查看日程详情
- (void)didReciveOpenToday:(NSNotification*)notification {

    //查看日程
    for (Calendar *calendar in [_userManager getCalendarArr]) {
        //去掉删除的
        if(calendar.status == 0) continue;
        if(calendar.id == [notification.object intValue]) {
            //展示详情
            if(calendar.repeat_type == 0) {
                Calendar *tempTemp = calendar;
                tempTemp.rdate = @([NSDate date].timeIntervalSince1970).stringValue;
                ComCalendarDetailViewController *vc = [ComCalendarDetailViewController new];
                vc.data = tempTemp;
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                Calendar *tempTemp = calendar;
                tempTemp.rdate = @([NSDate date].timeIntervalSince1970).stringValue;
                RepCalendarDetailController *vc = [RepCalendarDetailController new];
                vc.data = tempTemp;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
    }
}
#pragma mark -- 收到个推消息
- (void)didRecivePushMessage:(NSNotification*)notification {
    if(_userManager.user.canPlayVoice) {//声音
        AudioServicesPlaySystemSound(1007);
    }
    if(_userManager.user.canPlayShake)//震动
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
    //在这里处理个推推送
    NSData* payload = notification.object;
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length
                                            encoding:NSUTF8StringEncoding];
    }
    NSData *jsonData = [payloadMsg dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    //远程推送没有addTime和id 甚至没有unread，我们这里加上
    if(![dict.allKeys containsObject:@"unread"])
        [dict setObject:@(1) forKey:@"unread"];
    [dict setObject:@(-1 * [NSDate date].timeIntervalSince1970).stringValue forKey:@"id"];
    PushMessage *message = [PushMessage new];
    [message mj_setKeyValues:dict];
    message.addTime = [NSDate date];
    //公告
    if ([message.type isEqualToString:@"VOTE"] || [message.type isEqualToString:@"NOTICE"]) {
        message.to_user_no = _userManager.user.user_no;
    }
    //如果是分享过来的日程，存入数据库
    if ([message.type isEqualToString:@"CALENDAR"] && ![NSString isBlank:message.entity]) {
        NSData *calendarData = [[dict objectForKey:@"entity"] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
        Calendar *sharedCalendar = [Calendar new];
        [sharedCalendar mj_setKeyValues:calendarDic];
        sharedCalendar.descriptionStr = calendarDic[@"description"];
        if (sharedCalendar) {
            [_userManager addCalendar:sharedCalendar];
        }
    }
    //任务操作
    if ([message.type isEqualToString:@"TASK"]) {//任务推送
        //因为任务发送给你和任务状态改变和任务修改都是一样的action=GENERAL，所以这里我们这里要看本地是否有数据来判断是不是新添加的任务 以此来判断是否需要发送更新通知
        for (TaskModel *taskModel in [_userManager getTaskArr:message.company_no]) {
            if(message.target_id.intValue == taskModel.id) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTaskInfo" object:message];
            }
        }
        //获取任务详情 弹窗
        [UserHttp getTaskInfo:message.target_id.intValue handler:^(id data, MError *error) {
            if(error) return ;
            TaskModel *taskModel = [TaskModel new];
            [taskModel mj_setKeyValues:data];
            taskModel.descriptionStr = data[@"description"];
            [_userManager upadteTask:taskModel];
        }];
    }
    if([message.type isEqualToString:@"TASK_COMMENT_STATUS"]){//任务评论推送
        [UserHttp getTaskInfo:message.target_id.intValue handler:^(id data, MError *error) {
            if(error) return ;
            TaskModel *taskModel = [TaskModel new];
            [taskModel mj_setKeyValues:data];
            taskModel.descriptionStr = data[@"description"];
            [_userManager upadteTask:taskModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTaskInfo" object:message];
        }];
    }
    //圈子操作
    if ([message.type isEqualToString:@"COMPANY"]) {
        //同意加入圈子
        if ([message.action rangeOfString:@"COMPANY_ALLOW_JOIN"].location != NSNotFound) {
            //改变自己在里面的状态 更新圈子数组
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no];
            employee.status = 1;
            [_userManager updateEmployee:employee];
            //#BANG-585 web端申请-管理员手机端通过-ios不刷新
            BOOL localHaveThisCompany = NO;
            for (Company *company in [_userManager getCompanyArr]) {
                if(company.company_no == message.company_no) {
                    Company *tempCompany = company;
                    [_userManager deleteCompany:company];
                    [_userManager addCompany:tempCompany];
                    //如果没有加入圈子 则现在加入这个圈子
                    if(_userManager.user.currCompany.company_no == 0) {
                        _userManager.user.currCompany = tempCompany;
                        [_userManager updateUser:_userManager.user];
                    }
                    localHaveThisCompany = YES;
                    break;
                }
            }
            //如果是web端申请的 客户端讲没有数据，需要从网络获取一次
            if(localHaveThisCompany == NO) {
                //获取圈子详情
                [UserHttp getCompanyInfo:message.company_no handler:^(id data, MError *error) {
                    if(error) {
                        return ;
                    }
                    Company *company = [Company new];
                    [company mj_setKeyValues:data];
                    [_userManager addCompany:company];
                    //获取圈子员工列表
                    [UserHttp getEmployeeCompnyNo:message.company_no status:0 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                        if(error) {
                            return ;
                        }
                        NSMutableArray *array = [@[] mutableCopy];
                        for (NSDictionary *dic in data[@"list"]) {
                            Employee *employee = [Employee new];
                            [employee mj_setKeyValues:dic];
                            [array addObject:employee];
                        }
                        [UserHttp getEmployeeCompnyNo:message.company_no status:5 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                            if(error) {
                                return ;
                            }
                            for (NSDictionary *dic in data[@"list"]) {
                                Employee *employee = [Employee new];
                                [employee mj_setKeyValues:dic];
                                [array addObject:employee];
                            }
                            [_userManager updateEmployee:array companyNo:message.company_no];
                        }];
                    }];
                }];
            }
        }
        //同意退出圈子
        else if ([message.action rangeOfString:@"COMPANY_ALLOW_LEAVE"].location != NSNotFound){
            //改变自己在里面的状态 更新圈子数组
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no];
            employee.status = 2;
            [_userManager updateEmployee:employee];
            //改变自己在里面的状态 更新圈子数组
            for (Company *company in [_userManager getCompanyArr]) {
                if(company.company_no == message.company_no) {
                    [_userManager deleteCompany:company];
                    break;
                }
            }
            //重新让自己加入最近一个没有退出的圈子
            if(_userManager.user.currCompany.company_no == message.company_no) {
                Company *tempCompany = [Company new];
                for (Company *company in [_userManager getCompanyArr]) {
                    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
                    if(employee.status == 1 || employee.status == 4) {
                        tempCompany = company;
                        break;
                    }
                }
                _userManager.user.currCompany = tempCompany;
                [_userManager updateUser:_userManager.user];
            }
            //#BANG-490 退出圈子则需要默认选中第一行的圈子
            //如果没有加入圈子 则现在加入这个圈子
            if(_userManager.user.currCompany.company_no == 0) {
                for (Company *company in [_userManager getCompanyArr]) {
                    if(company.company_no == message.company_no) {
                        _userManager.user.currCompany = company;
                        [_userManager updateUser:_userManager.user];
                        break;
                    }
                }
            }
        }
        //拒绝加入圈子
        else if ([message.action rangeOfString:@"COMPANY_REFUSE_JOIN"].location != NSNotFound) {
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no];
            employee.status = 3;
            [_userManager updateEmployee:employee];
        }
        //转让圈子 修改圈子的创建者为自己
        else if ([message.action rangeOfString:@"COMPANY_TRANSFER"].location != NSNotFound) {
            NSArray *array = [_userManager getCompanyArr];
            Employee * employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no];
            for (Company *company in array) {
                if(company.company_no == message.company_no) {
                    Company *temp = company;
                    temp.admin_user_guid = employee.user_guid;
                    [_userManager updateCompany:temp];
                    //如果自己在当前圈子 还要更新用户信息
                    if(_userManager.user.currCompany.company_no == company.company_no) {
                        _userManager.user.currCompany = company;
                        [_userManager updateUser:_userManager.user];
                    }
                    break;
                }
            }
        }
        //拒绝离开圈子 改变员工状态
        else if ([message.action rangeOfString:@"COMPANY_REFUSE_LEAVE"].location != NSNotFound) {
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no];
            employee.status = 1;
            [_userManager updateEmployee:employee];
        } else {
            //某某某请求加入/退出圈子  获取所有状态的员工 更新
            //#BANG-354 不自动切换圈子
            //        for (Company *company in [_userManager getCompanyArr]) {
            //            if(company.company_no == message.company_no) {
            //                Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
            //                if(employee.status == 1 || employee.status == 4) {
            //                    User *user = [_userManager.user deepCopy];
            //                    user.currCompany = company;
            //                    [_userManager updateUser:user];
            //                }
            //                break;
            //            }
            //        }
            [UserHttp getEmployeeCompnyNo:message.company_no status:0 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                if(error) {
                    return ;
                }
                NSMutableArray *array = [@[] mutableCopy];
                for (NSDictionary *dic in data[@"list"]) {
                    Employee *employee = [Employee new];
                    [employee mj_setKeyValues:dic];
                    [array addObject:employee];
                }
                [UserHttp getEmployeeCompnyNo:message.company_no status:4 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                    if(error) {
                        return ;
                    }
                    for (NSDictionary *dic in data[@"list"]) {
                        Employee *employee = [Employee new];
                        [employee mj_setKeyValues:dic];
                        [array addObject:employee];
                    }
                    //存入本地数据库
                    for (Employee *employee in array) {
                        [_userManager updateEmployee:employee];
                    }
                }];
            }];
        }
    }
    if ([message.action rangeOfString:@"CHANGE_PASSWORD"].location != NSNotFound) { //修改密码
        //这里判断一下是不是有用户登录
        //#BANG-417 服务器已经修改，登陆界面修改密码不要推送消息
        //        if(![NSString isBlank:[IdentityManager manager].identity.user_guid]) {
        [[IdentityManager manager] logOut];
        [[IdentityManager manager] showLogin:@"你已修改密码，请重新登录"];
        //        }
    }
    if([message.type isEqualToString:@"MEETING"]) {
        if([message.action isEqualToString:@"GENERAL"]) {//如果是有会议来
            
        } else {
            NSData *calendarData = [[dict objectForKey:@"entity"] dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
            Calendar *meetingCalendar = [Calendar new];
            [meetingCalendar mj_setKeyValues:calendarDic];
            meetingCalendar.descriptionStr = calendarDic[@"description"];
            if([message.action isEqualToString:@"MEETING_RECEIVE"]){//接收会议 加入本地日程
                [_userManager addCalendar:meetingCalendar];
            } else if ([message.action isEqualToString:@"MEETING_FINISHED"]) {//会议完结 本地的日程完结
                meetingCalendar.status = 2;
                [_userManager updateCalendar:meetingCalendar];
            } else if ([message.action isEqualToString:@"MEETING_UPDATE"]) {//更新会议 更新本地日程
                [_userManager updateCalendar:meetingCalendar];
            } else if ([message.action isEqualToString:@"MEETING_CALLOFF"]) {//取消会议
                meetingCalendar.status = 0;
                [_userManager updateCalendar:meetingCalendar];
            }
        }
    }
    [_userManager addPushMessage:message];
}
//3d touch进入应用
- (void)didReciveTouch:(NSNotification*)notification {
    int currIndex = [notification.object intValue];
    if(currIndex == 0) {//今日日程
        [self.navigationController pushViewController:[CalendarController new] animated:YES];
    } else if (currIndex == 1) {//签到
        [self executeNeedSelectCompany:^{
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
            CreateSiginController *sigin = [story instantiateViewControllerWithIdentifier:@"CreateSiginController"];
            [self.navigationController pushViewController:sigin animated:YES];
        }];
    }
}
//需要选择圈子后才能操作
- (void)executeNeedSelectCompany:(void (^)(void))aBlock
{
    if(_userManager.user.currCompany.company_no == 0) {
        [self.navigationController.view showMessageTips:@"请选择一个圈子后再进行此操作"];
        return;
    }
    aBlock();
}
//这里写回调
#pragma mark --
#pragma mark -- MoreViewControllerDelegate
- (void)MoreViewDidClicked:(int)index {
    if(index == 6) {//投票
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Vote?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 5) {//审批
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@ApprovalByFormBuilder?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 4) {//动态
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Dynamic?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 3) {//日程
        [self.navigationController pushViewController:[CalendarCreateController new] animated:YES];
    } else if (index == 2) {//任务
        [self executeNeedSelectCompany:^{
            [self.navigationController pushViewController:[TaskCreateController new] animated:YES];
        }];
    } else if (index == 1) {//邮箱
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
    } else {//会议
        [self executeNeedSelectCompany:^{
            [self.navigationController pushViewController:[CreateMeetingController new] animated:YES];
        }];
    }
}
#pragma mark --
#pragma mark -- UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if([viewController isMemberOfClass:[UIViewController class]]) {
        //在这里加上一个选择视图控制器
        MoreSelectController *more = [MoreSelectController new];
        more.view.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
        more.delegate = self;
        [self addChildViewController:more];
        [self.view addSubview:more.view];
        return NO;
    }
    return YES;
}
//- (void)insertSearchableItem:(NSData *)photo spotlightTitle:(NSString *)spotlightTitle description:(NSString *)spotlightDesc keywords:(NSArray *)keywords spotlightInfo:(NSString *)spotlightInfo domainId:(NSString *)domainId {
//    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeImage];
//    attributeSet.title = spotlightTitle;                // 标题
//    attributeSet.keywords = keywords;                   // 关键字,NSArray格式
//    attributeSet.contentDescription = spotlightDesc;    // 描述
//    attributeSet.thumbnailData = photo;                 // 图标, NSData格式
//    // spotlightInfo 可以作为一些数据传递给接受的地方
//    // domainId      id,通过这个id来判断是哪个spotlight
//    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:spotlightInfo domainIdentifier:domainId attributeSet:attributeSet];
//    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:^(NSError * error) {}];
//}
#pragma mark --
#pragma mark -- Custom
- (UINavigationController*)homeListController {
    HomeListController *home = [HomeListController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"首页";
    nav.navigationBar.translucent = NO;
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} forState:UIControlStateSelected];
    nav.tabBarItem.image = [[UIImage imageNamed:@"index-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"index-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
- (UINavigationController*)xAddrBookController {
    XAddrBookController *home = [XAddrBookController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"联系人";
    nav.navigationBar.translucent = NO;
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} forState:UIControlStateSelected];
    nav.tabBarItem.image = [[UIImage imageNamed:@"set-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"set-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
- (UIViewController*)centerController {
    UIViewController *view = [UIViewController new];
    view.tabBarItem.image = [[UIImage imageNamed:@"home_add"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    view.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    return view;
}
- (UINavigationController*)messageController {
    MessageController *home = [MessageController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"会话";
    nav.navigationBar.translucent = NO;
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} forState:UIControlStateSelected];
    nav.tabBarItem.image = [[UIImage imageNamed:@"message-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"message-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
- (UINavigationController*)mineViewController {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
    MineViewController *home = [story instantiateViewControllerWithIdentifier:@"MineViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"我的";
    nav.navigationBar.translucent = NO;
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} forState:UIControlStateSelected];
    nav.tabBarItem.image = [[UIImage imageNamed:@"contact-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"contact-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}

@end
