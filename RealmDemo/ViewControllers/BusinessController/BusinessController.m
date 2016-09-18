//
//  BusinessController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "BusinessController.h"
#import "REFrostedViewController.h"
#import "MainBusinessController.h"
#import "LeftMenuController.h"
#import "UserHttp.h"
#import "UserManager.h"

@interface BusinessController () {
    UserManager *_userManager;
    UINavigationController *_businessNav;
    NSMutableArray *_needSyncCalender;
}

@end

@implementation BusinessController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    self.view.backgroundColor = [UIColor whiteColor];
    //创建界面
    REFrostedViewController *_rEFrostedView = [[REFrostedViewController alloc] initWithContentViewController:[MainBusinessController new] menuViewController:[LeftMenuController new]];
    _rEFrostedView.direction = REFrostedViewControllerDirectionLeft;
    _rEFrostedView.menuViewSize = CGSizeMake(MAIN_SCREEN_WIDTH * 3 / 4, MAIN_SCREEN_HEIGHT);
    _rEFrostedView.liveBlur = YES;
    //这个导航用于弹出通知信息，是业务模块的根控制器
    _businessNav = [[UINavigationController alloc] initWithRootViewController:_rEFrostedView];
    [self addChildViewController:_businessNav];
    [_businessNav.view willMoveToSuperview:self.view];
    [_businessNav willMoveToParentViewController:self];
    [_businessNav setNavigationBarHidden:YES animated:YES];
    _businessNav.navigationBar.translucent = NO;
    _businessNav.navigationBar.barTintColor = [UIColor colorWithRed:8/255.f green:21/255.f blue:63/255.f alpha:1];
    [self.view addSubview:_businessNav.view];
    //检查网络是否连接
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //这里进程序就会回调一次 所以可以在这里进行程序进入后加载所需要的最新数据 进入时加载必要的最新数据
        if(status == -1 || status == 0) {
            [_businessNav.view showFailureTips:@"网络不可用，请连接网络"];
            return;
        }
        if(!_userManager.user.currCompany.company_no) return;
        [self getCompanySiginRule];//获取签到规则
        [self getCurrcompanyTasks];//获取任务
        [self checkSyncCalender];//同步日程
    }];
}
//获取圈子信息
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
            SiginRuleSet *set = [[SiginRuleSet alloc] initWithJSONDictionary:dicDic];
            //这里动态添加签到地址
            RLMArray<PunchCardAddressSetting> *settingArr = [[RLMArray<PunchCardAddressSetting> alloc] initWithObjectClassName:@"PunchCardAddressSetting"];
            for (NSDictionary *settingDic in dicDic[@"address_settings"]) {
                PunchCardAddressSetting *setting = [[PunchCardAddressSetting alloc] initWithJSONDictionary:settingDic];
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
            TaskModel *model = [[TaskModel alloc] initWithJSONDictionary:dic];
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
        if(calender.needSync == YES)
            [_needSyncCalender addObject:calender];
    }
    if(!_needSyncCalender.count) return;
    [_businessNav.view showLoadingTips:@"上传离线日程..."];
    [self syncCalender];
    
}
- (void)syncCalender {
    if(_needSyncCalender.count == 0) {
        [_businessNav.view dismissTips];
        return;
    }
    [UserHttp createUserCalendar:_needSyncCalender[0] handler:^(id data, MError *error) {
        if(error) {
            [_businessNav.view showFailureTips:error.statsMsg];
            return ;
        }
        [_userManager delCalendar:_needSyncCalender[0]];
        [_needSyncCalender removeObjectAtIndex:0];
        Calendar *calendar = [Calendar new];
        [calendar mj_setKeyValues:data];
        calendar.descriptionStr = data[@"description"];
        [_userManager addCalendar:calendar];
        [self syncCalender];
    }];
}

@end
