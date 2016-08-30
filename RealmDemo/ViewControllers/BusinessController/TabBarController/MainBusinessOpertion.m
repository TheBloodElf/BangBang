//
//  MainBusinessOpertion.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MainBusinessOpertion.h"
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

@interface MainBusinessOpertion () {
    UserManager *_userManager;
    IdentityManager *_identityManager;
}

@end

@implementation MainBusinessOpertion

- (void)startConnect {
    _userManager = [UserManager manager];
    _identityManager = [IdentityManager manager];
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
}
//Spotlight进来的
- (void)didReciveOpenSpotlight:(NSNotification*)notification {
    //    NSString *currStr = notification.object;
}
//Today进来 添加日程
- (void)didReciveAddToday:(NSNotification*)notification {
    //添加日程
    [self.mainBusinessController.navigationController pushViewController:[CalendarCreateController new] animated:YES];
}
//Today进来 查看日程详情
- (void)didReciveOpenToday:(NSNotification*)notification {
    //查看日程
    for (Calendar *calendar in [_userManager getCalendarArr]) {
        if(calendar.id == [notification.object intValue]) {
            //展示详情
            if(calendar.repeat_type == 0) {
                Calendar *tempTemp = [calendar deepCopy];
                tempTemp.rdate = @([NSDate date].timeIntervalSince1970).stringValue;
                [self.mainBusinessController.navigationController pushControler:@"ComCalendarDetailViewController" parameters:@{@"calendar":tempTemp}];
            } else {
                Calendar *tempTemp = [calendar deepCopy];
                tempTemp.rdate = @([NSDate date].timeIntervalSince1970).stringValue;
                [self.mainBusinessController.navigationController pushControler:@"RepCalendarDetailController" parameters:@{@"calendar":tempTemp}];
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
        //获取任务详情 弹窗
        [UserHttp getTaskInfo:message.target_id.intValue handler:^(id data, MError *error) {
            if(error) {
                [self.mainBusinessController.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            TaskModel *taskModel = [[TaskModel alloc] initWithJSONDictionary:data];
            taskModel.descriptionStr = data[@"description"];
            [_userManager upadteTask:taskModel];
            
            TaskDetailController *task = [TaskDetailController new];
            task.data = taskModel;
            [self.mainBusinessController.navigationController pushViewController:task animated:YES];
        }];
    } else if([message.type isEqualToString:@"WORKTIP"]){//上下班提醒
        
    } else if([message.type isEqualToString:@"TASK_COMMENT_STATUS"]){//任务评论推送
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTaskInfo" object:message];
    } else if([message.type isEqualToString:@"TASKTIP"]) { //任务提醒推送 进入任务详情
        for (TaskModel *taskModel in [_userManager getTaskArr:message.company_no]) {
            if(message.target_id.intValue == taskModel.id) {
                TaskDetailController *task = [TaskDetailController new];
                task.data = taskModel;
                [self.mainBusinessController.navigationController pushViewController:task animated:YES];
                break;
            }
        }
    } else if([message.type isEqualToString:@"CALENDARTIP"]) {//日程提醒 进入日程详情
        for (Calendar *calendar in [_userManager getCalendarArr]) {
            if(calendar.id == message.target_id.intValue) {
                //展示详情
                if(calendar.repeat_type == 0) {
                    Calendar *tempTemp = [calendar deepCopy];
                    tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                    [self.mainBusinessController.navigationController pushControler:@"ComCalendarDetailViewController" parameters:@{@"calendar":tempTemp}];
                } else {
                    Calendar *tempTemp = [calendar deepCopy];
                    tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                    [self.mainBusinessController.navigationController pushControler:@"RepCalendarDetailController" parameters:@{@"calendar":tempTemp}];
                }
                break;
            }
        }
    } else if([message.type isEqualToString:@"CALENDAR"]){ //日程推送 分享日程
        NSData *calendarData = [message.entity dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
        Calendar *sharedCalendar = [[Calendar alloc] initWithJSONDictionary:calendarDic];
        sharedCalendar.descriptionStr = calendarDic[@"description"];
        //展示详情
        if(sharedCalendar.repeat_type == 0) {
            Calendar *tempTemp = [sharedCalendar deepCopy];
            tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
            [self.mainBusinessController.navigationController pushControler:@"ComCalendarDetailViewController" parameters:@{@"calendar":tempTemp}];
        } else {
            Calendar *tempTemp = [sharedCalendar deepCopy];
            tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
            [self.mainBusinessController.navigationController pushControler:@"RepCalendarDetailController" parameters:@{@"calendar":tempTemp}];
        }
    }else if ([message.type isEqualToString:@"REQUEST"]) {//网页
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@request/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.mainBusinessController.navigationController pushViewController:webViewcontroller animated:NO];
    }else if ([message.type isEqualToString:@"APPROVAL"]){//通用审批
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Approval/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.mainBusinessController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if ([message.type isEqualToString:@"NEW_APPROVAL"]){//审批
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@ApprovalByFormBuilder/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.mainBusinessController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"MAIL"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Mail/Details?id=%@&isSend=false&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.mainBusinessController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"MEETING"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Meeting/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.mainBusinessController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"VOTE"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Vote/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.mainBusinessController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"NOTICE"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@NOTICE/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.mainBusinessController.navigationController pushViewController:webViewcontroller animated:NO];
    }
}
//3d touch进入应用
- (void)didReciveTouch:(NSNotification*)notification {
    int currIndex = [notification.object intValue];
    if(currIndex == 0) {//今日日程
        [self.mainBusinessController.navigationController pushViewController:[CalendarController new] animated:YES];
    } else if (currIndex == 1) {//签到
        [self executeNeedSelectCompany:^{
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
            CreateSiginController *sigin = [story instantiateViewControllerWithIdentifier:@"CreateSiginController"];
            [self.mainBusinessController.navigationController pushViewController:sigin animated:YES];
        }];
    }
}
//需要选择圈子后才能操作
- (void)executeNeedSelectCompany:(void (^)(void))aBlock
{
    if([UserManager manager].user.currCompany.company_no == 0) {
        [self.mainBusinessController.navigationController.view showMessageTips:@"请选择一个圈子后再进行此操作"];
        return;
    }
    aBlock();
}
//这里写回调
#pragma mark -- MoreViewControllerDelegate
- (void)MoreViewDidClicked:(int)index {
    if(index == 6) {//投票
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Vote?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self.mainBusinessController navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 5) {//审批
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@ApprovalByFormBuilder?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self.mainBusinessController navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 4) {//动态
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Dynamic?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self.mainBusinessController navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 3) {//日程
        [self.mainBusinessController.navigationController pushViewController:[CalendarCreateController new] animated:YES];
    } else if (index == 2) {//任务
        [self executeNeedSelectCompany:^{
            [self.mainBusinessController.navigationController pushViewController:[TaskCreateController new] animated:YES];
        }];
    } else if (index == 1) {//邮箱
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
    } else {//会议
        [self executeNeedSelectCompany:^{
            [self.mainBusinessController.navigationController pushViewController:[CreateMeetingController new] animated:YES];
        }];
    }
}
#pragma mark -- UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if([viewController isMemberOfClass:[UIViewController class]]) {
        //在这里加上一个选择视图控制器
        MoreSelectController *more = [MoreSelectController new];
        more.view.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
        more.delegate = self;
        [self.mainBusinessController addChildViewController:more];
        [self.mainBusinessController.view addSubview:more.view];
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
@end
