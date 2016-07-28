//
//  BusinessController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "BusinessController.h"
#import "REFrostedViewController.h"
#import "LeftMenuController.h"
#import "RequestManagerController.h"
#import "BushManageViewController.h"
#import "WebNonstandarViewController.h"
#import "RepCalendarDetailController.h"
#import "ComCalendarDetailViewController.h"
#import "TabBarController.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "IdentityManager.h"

@interface BusinessController () {
    UserManager *_userManager;
    IdentityManager *_identityManager;
    UINavigationController *_businessNav;//这个导航用于弹出通知信息，所以多了这一层
    REFrostedViewController *_rEFrostedView;//侧滑控制器
}
@end

@implementation BusinessController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    _identityManager = [IdentityManager manager];
    self.view.backgroundColor = [UIColor whiteColor];
    //创建界面
    _rEFrostedView = [[REFrostedViewController alloc] initWithContentViewController:[TabBarController new] menuViewController:[LeftMenuController new]];
    _rEFrostedView.direction = REFrostedViewControllerDirectionLeft;
    _rEFrostedView.menuViewSize = CGSizeMake(MAIN_SCREEN_WIDTH*3/4, MAIN_SCREEN_HEIGHT + 44);
    _rEFrostedView.liveBlur = YES;
    //创建业务根视图控制器
    _businessNav = [[UINavigationController alloc] initWithRootViewController:_rEFrostedView];
    [self addChildViewController:_businessNav];
    [_businessNav.view willMoveToSuperview:self.view];
    [_businessNav willMoveToParentViewController:self];
    [_businessNav setNavigationBarHidden:YES animated:YES];
    _businessNav.navigationBar.translucent = NO;
    _businessNav.navigationBar.barTintColor = [UIColor homeListColor];
    [_businessNav.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.view addSubview:_businessNav.view];
    //加上新消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecivePushMessage:) name:@"DidRecivePushMessage" object:nil];
    // Do any additional setup after loading the view.
}
//在这里统一处理弹窗
- (void)didRecivePushMessage:(NSNotification*)notification {
    PushMessage *message = notification.object;
    //如果是圈子操作
    if([message.type isEqualToString:@"COMPANY"]) {
        //是否有操作
        if ([message.action isEqualToString:@"GENERAL"]) {
            [_businessNav pushViewController:[RequestManagerController new] animated:YES];
        } else {
            [_businessNav pushViewController:[BushManageViewController new] animated:YES];
        }
    } else if ([message.type isEqualToString:@"TASK"]) {//任务推送
        
    } else if([message.type isEqualToString:@"TASK_COMMENT_STATUS"]){//任务评论推送
        
    } else if([message.type isEqualToString:@"TASKTIP"]) { //任务提醒推送
        
    } else if([message.type isEqualToString:@"CALENDAR"]){ //日程推送 分享日程
        NSArray *array = [_userManager getCalendarArr];
        Calendar *calendar = nil;
        for (Calendar *temp in array) {
            if(temp.id == [message.target_id intValue]) {
                calendar = temp;
                break;
            }
        }
        //展示详情
        if(calendar.repeat_type == 0) {
            ComCalendarDetailViewController *com = [ComCalendarDetailViewController new];
            com.data = calendar;
            [_businessNav pushViewController:com animated:YES];
        } else {
            RepCalendarDetailController *com = [RepCalendarDetailController new];
            com.data = calendar;
            [_businessNav pushViewController:com animated:YES];
        }
    }else if ([message.type isEqualToString:@"REQUEST"]) {//网页
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@request/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.frostedViewController.navigationController pushViewController:webViewcontroller animated:NO];
    }else if ([message.type isEqualToString:@"APPROVAL"]){//通用审批
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Approval/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.frostedViewController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if ([message.type isEqualToString:@"NEW_APPROVAL"]){//审批
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@ApprovalByFormBuilder/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%ld",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
        [self.frostedViewController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"MAIL"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Mail/Details?id=%@&isSend=false&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.frostedViewController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"MEETING"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Meeting/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.frostedViewController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"VOTE"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Vote/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.frostedViewController.navigationController pushViewController:webViewcontroller animated:NO];
    } else if([message.type isEqualToString:@"NOTICE"]){
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@NOTICE/Details?id=%@&userGuid=%@&companyNo=%ld&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
        [self.frostedViewController.navigationController pushViewController:webViewcontroller animated:NO];
    }
}
@end
