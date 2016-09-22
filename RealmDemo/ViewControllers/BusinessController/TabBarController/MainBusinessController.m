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

@interface MainBusinessController ()<UITabBarControllerDelegate,MoreViewControllerDelegate> {
    UITabBarController *_tabBarVC;
    UserManager *_userManager;
    IdentityManager *_identityManager;
    NSMutableArray *_needSyncCalender;//需要同步的日程
}

@end

@implementation MainBusinessController

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
    //加上新消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecivePushMessage:) name:@"DidRecivePushMessage" object:nil];
    //加上从today进来的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveAddToday:) name:@"OpenSoft_FormToday_addCalendar_Notication" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveOpenToday:) name:@"OpenSoft_FormToday_openCalendar_Notication" object:nil];
    //添加spotlight索引 我们要适配IOS8所以这个功能不能用
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f) {
        [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {}];
        [self insertSearchableItem:UIImagePNGRepresentation([UIImage imageNamed:@"default_image_icon"]) spotlightTitle:@"帮帮管理助手" description:@"身边不可获取的办公软件" keywords:@[@"日程",@"任务",@"会议",@"签到"] spotlightInfo:@"OpenSoft" domainId:@"com.lottak.BangBang"];
    }
    //加上spotlight进来的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveOpenSpotlight:) name:@"OpenSoft_FormSpotlight_Notication" object:nil];
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
        [self getCompanySiginRule];//获取签到规则
//        [self getCurrcompanyTasks];//获取任务
        [self checkSyncCalender];//同步日程
    }];
}
#pragma mark --
#pragma mark -- 这里是需要有网就操作的
//获取签到规则
- (void)getCompanySiginRule {
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
//获取当前圈子的任务列表
- (void)getCurrcompanyTasks {
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    [UserHttp getTaskList:employee.employee_guid handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray<TaskModel*> *array = [@[] mutableCopy];
        for (NSDictionary *dic in data[@"list"]) {
            TaskModel *model = [TaskModel new];
            [model mj_setKeyValues:dic];
            model.descriptionStr = dic[@"description"];
            [array addObject:model];
        }
        [_userManager updateTask:array companyNo:_userManager.user.currCompany.company_no];
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
    Calendar *calendar = [_needSyncCalender.firstObject deepCopy];
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
            [UserHttp syncUserCalendar:calendar handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController.view dismissTips];
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                calendar.needSync = NO;
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
- (void)didReciveOpenSpotlight:(NSNotification*)notification {
    //    NSString *currStr = notification.object;
}
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
                Calendar *tempTemp = [calendar deepCopy];
                tempTemp.rdate = @([NSDate date].timeIntervalSince1970).stringValue;
                ComCalendarDetailViewController *vc = [ComCalendarDetailViewController new];
                vc.data = tempTemp;
                [self.navigationController pushViewController:vc animated:YES];
                
            } else {
                Calendar *tempTemp = [calendar deepCopy];
                tempTemp.rdate = @([NSDate date].timeIntervalSince1970).stringValue;
                RepCalendarDetailController *vc = [RepCalendarDetailController new];
                vc.data = tempTemp;
                [self.navigationController pushViewController:vc animated:YES];
            }
            break;
        }
    }
}
//推送消息
- (void)didRecivePushMessage:(NSNotification*)notification {
    PushMessage *message = notification.object;
    //如果是圈子操作
    if([message.type isEqualToString:@"COMPANY"]) {
        //是否有操作
        if ([message.action isEqualToString:@"GENERAL"]) { //都不管 因为要不停的弹出来 很烦
            //            [_businessNav pushViewController:[RequestManagerController new] animated:YES];
        } else {
            //其他的不用管
        }
    } else if ([message.type isEqualToString:@"TASK"]) {//任务推送
        //因为任务发送给你和任务状态改变都是一样的action=GENERAL，所以这里我们这里要看本地是否有数据来判断是不是新添加的任务 以此来判断是否需要发送更新通知
        for (TaskModel *taskModel in [_userManager getTaskArr:message.company_no]) {
            if(message.target_id.intValue == taskModel.id) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTaskInfo" object:message];
            }
        }
        //获取任务详情 弹窗
        [UserHttp getTaskInfo:message.target_id.intValue handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            TaskModel *taskModel = [TaskModel new];
            [taskModel mj_setKeyValues:data];
            taskModel.descriptionStr = data[@"description"];
            [_userManager upadteTask:taskModel];
            
            TaskDetailController *task = [TaskDetailController new];
            task.data = taskModel;
            [self.navigationController pushViewController:task animated:YES];
        }];
    } else if([message.type isEqualToString:@"TASK_COMMENT_STATUS"]){//任务评论推送
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTaskInfo" object:message];
    } else if([message.type isEqualToString:@"WORKTIP"]){//上下班提醒
        
    } else if([message.type isEqualToString:@"TASKTIP"]) { //任务提醒推送 进入任务详情
        for (TaskModel *taskModel in [_userManager getTaskArr:message.company_no]) {
            if(message.target_id.intValue == taskModel.id) {
                TaskDetailController *task = [TaskDetailController new];
                task.data = taskModel;
                [self.navigationController pushViewController:task animated:YES];
                break;
            }
        }
    } else if([message.type isEqualToString:@"CALENDARTIP"]) {//日程提醒 进入日程详情
        for (Calendar *calendar in [_userManager getCalendarArr]) {
            //去掉删除的
            if(calendar.status == 0) continue;
            if(calendar.id == message.target_id.intValue) {
                //展示详情
                if(calendar.repeat_type == 0) {
                    Calendar *tempTemp = [calendar deepCopy];
                    tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                    ComCalendarDetailViewController *vc = [ComCalendarDetailViewController new];
                    vc.data = tempTemp;
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    Calendar *tempTemp = [calendar deepCopy];
                    tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                    RepCalendarDetailController *vc = [RepCalendarDetailController new];
                    vc.data = tempTemp;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            }
        }
    } else if([message.type isEqualToString:@"CALENDAR"]){ //日程推送 分享日程
        NSData *calendarData = [message.entity dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
        Calendar *sharedCalendar = [Calendar new];
        [sharedCalendar mj_setKeyValues:calendarDic];
        sharedCalendar.descriptionStr = calendarDic[@"description"];
        //展示详情
        if(sharedCalendar.repeat_type == 0) {
            Calendar *tempTemp = [sharedCalendar deepCopy];
            tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
            ComCalendarDetailViewController *vc = [ComCalendarDetailViewController new];
            vc.data = tempTemp;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            Calendar *tempTemp = [sharedCalendar deepCopy];
            tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
            RepCalendarDetailController *vc = [RepCalendarDetailController new];
            vc.data = tempTemp;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if ([message.type isEqualToString:@"REQUEST"]) {//网页
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@request/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    }else if ([message.type isEqualToString:@"APPROVAL"]){//通用审批
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Approval/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if ([message.type isEqualToString:@"NEW_APPROVAL"]){//审批
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@ApprovalByFormBuilder/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"MAIL"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Mail/Details?id=%@&isSend=false&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"MEETING"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Meeting/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"VOTE"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Vote/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"NOTICE"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@NOTICE/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:NO];
    }
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
    if([UserManager manager].user.currCompany.company_no == 0) {
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
            NSString *str = [NSString stringWithFormat:@"%@Vote?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 5) {//审批
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@ApprovalByFormBuilder?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 4) {//动态
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Dynamic?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
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
- (void)insertSearchableItem:(NSData *)photo spotlightTitle:(NSString *)spotlightTitle description:(NSString *)spotlightDesc keywords:(NSArray *)keywords spotlightInfo:(NSString *)spotlightInfo domainId:(NSString *)domainId {
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeImage];
    attributeSet.title = spotlightTitle;                // 标题
    attributeSet.keywords = keywords;                   // 关键字,NSArray格式
    attributeSet.contentDescription = spotlightDesc;    // 描述
    attributeSet.thumbnailData = photo;                 // 图标, NSData格式
    // spotlightInfo 可以作为一些数据传递给接受的地方
    // domainId      id,通过这个id来判断是哪个spotlight
    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:spotlightInfo domainIdentifier:domainId attributeSet:attributeSet];
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:^(NSError * error) {}];
}
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
