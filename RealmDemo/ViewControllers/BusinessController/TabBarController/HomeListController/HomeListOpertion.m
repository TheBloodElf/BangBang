//
//  HomeListOpertion.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HomeListOpertion.h"
#import "AppListController.h"
#import "UserHttp.h"
#import "IdentityManager.h"
#import "CalendarController.h"
#import "TaskListController.h"
#import "WebNonstandarViewController.h"
#import "SiginController.h"

@interface HomeListOpertion () {
    UserManager *_userManager;
    RBQFetchedResultsController *_sigRuleFetchedResultsController;
}

@end

@implementation HomeListOpertion

- (void)startConnect {
    _userManager = [UserManager manager];
    _sigRuleFetchedResultsController = [_userManager createSiginRuleFetchedResultsController:_userManager.user.currCompany.company_no];
    _sigRuleFetchedResultsController.delegate = self;
    _sigRuleFetchedResultsController.data = @"sigRuleFetchedResultsController";
    //在这里统一获取一些必须获取的值
    //从服务器获取一次规则
    [UserHttp getSiginRule:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
        if(error) {
            [self.homeListController.navigationController.view showFailureTips:error.statsMsg];
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

#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if([controller.data isEqualToString:@"pushMessageFetchedResultsController"]) {
        PPDragDropBadgeView *label = [self.homeListController.rightNavigationBarButton viewWithTag:1001];
        int count = 0;
        for (PushMessage *push in controller.fetchedObjects) {
            if(push.unread == YES)
                count ++;
        }
        label.text = [NSString stringWithFormat:@"%d",count];
    } else if([controller.data isEqualToString:@"userFetchedResultsController"]) {
        User *user = [_userManager user];
        //重新设置签到记录的数据监听
        _sigRuleFetchedResultsController = [_userManager createSiginRuleFetchedResultsController:user.currCompany.company_no];
        _sigRuleFetchedResultsController.delegate = self;
        UIImageView *imageView = [self.homeListController.leftNavigationBarButton viewWithTag:1001];
        UILabel *nameLabel = [self.homeListController.leftNavigationBarButton viewWithTag:1002];
        UILabel *companyLabel = [self.homeListController.leftNavigationBarButton viewWithTag:1003];
        [imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        nameLabel.text = user.real_name;
        if([NSString isBlank:user.currCompany.company_name])
            companyLabel.text = @"未选择圈子";
        else {
            companyLabel.text = user.currCompany.company_name;
            //圈子变了 就要获取一次对应圈子的签到规则
            //从服务器获取一次规则
            [UserHttp getSiginRule:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
                if(error) {
                    [self.homeListController.navigationController.view showFailureTips:error.statsMsg];
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
    } else {//重新加一次上下班提醒
        [_userManager addSiginRuleNotfition];
    }
}
#pragma mark --
#pragma mark -- HomeListTopDelegate
//需要选择圈子后才能操作
- (void)executeNeedSelectCompany:(void (^)(void))aBlock
{
    if(_userManager.user.currCompany.company_no == 0) {
        [self.homeListController.navigationController.view showMessageTips:@"请选择一个圈子后再进行此操作"];
        return;
    }
    aBlock();
}
//今天完成日程被点击
- (void)todayFinishCalendar {
    CalendarController *calendar = [CalendarController new];
    calendar.hidesBottomBarWhenPushed = YES;
    [self.homeListController.navigationController pushViewController:calendar animated:YES];
}
//本周完成日程被点击
- (void)weekFinishCalendar {
    CalendarController *calendar = [CalendarController new];
    calendar.hidesBottomBarWhenPushed = YES;
    [self.homeListController.navigationController pushViewController:calendar animated:YES];
}
//我委派的任务被点击
- (void)createTaskClicked {
    [self executeNeedSelectCompany:^{
        TaskListController *list = [TaskListController new];
        list.type = 1;
        list.hidesBottomBarWhenPushed = YES;
        [self.homeListController.navigationController pushViewController:list animated:YES];
    }];
}
//我负责的任务被点击
- (void)chargeTaskClicked {
    [self executeNeedSelectCompany:^{
        TaskListController *list = [TaskListController new];
        list.type = 0;
        list.hidesBottomBarWhenPushed = YES;
        [self.homeListController.navigationController pushViewController:list animated:YES];
    }];
}
#pragma mark --
#pragma mark -- HomeListBottomDelegate
- (void)homeListBottomLocalAppSelect:(LocalUserApp*)localUserApp {
    if([localUserApp.titleName isEqualToString:@"公告"]) {//公告
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Notice?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self.homeListController navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if ([localUserApp.titleName isEqualToString:@"动态"]) {//动态
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Dynamic?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self.homeListController navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if ([localUserApp.titleName isEqualToString:@"签到"]) {//签到
        [self executeNeedSelectCompany:^{
            SiginController *sigin = [SiginController new];
            sigin.hidesBottomBarWhenPushed = YES;
            [self.homeListController.navigationController pushViewController:sigin animated:YES];
        }];
    } else if([localUserApp.titleName isEqualToString:@"审批"]) {//审批
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@ApprovalByFormBuilder?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self.homeListController navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if ([localUserApp.titleName isEqualToString:@"邮件"]) {//邮件 调用手机上的邮件
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
    } else if ([localUserApp.titleName isEqualToString:@"会议"]) {//会议
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@meeting?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self.homeListController navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if([localUserApp.titleName isEqualToString:@"投票"]){//投票
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Vote?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self.homeListController navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    }
}
//更多
- (void)homeListBottomMoreApp {
    AppListController *appList = [AppListController new];
    appList.hidesBottomBarWhenPushed = YES;
    [self.homeListController.navigationController pushViewController:appList animated:YES];
}

@end
