//
//  HomeListController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HomeListController.h"
#import "HomeListTopView.h"
#import "HomeListBottomView.h"
#import "UserManager.h"
#import "SiginController.h"
#import "CalendarController.h"
#import "WebNonstandarViewController.h"
#import "PushMessageController.h"
#import "TaskListController.h"
#import "IdentityManager.h"
#import "UserHttp.h"

@interface HomeListController ()<HomeListTopDelegate,HomeListBottomDelegate,RBQFetchedResultsControllerDelegate> {
    UIScrollView *_scrollView;//整体的滚动视图
    HomeListTopView *_homeListTopView;//头部数据视图
    HomeListBottomView *_homeListBottomView;//底部的按钮视图
    UIButton *_leftNavigationBarButton;//左边导航的按钮
    UIButton *_rightNavigationBarButton;//右边导航的按钮
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据库监听
    RBQFetchedResultsController *_pushMessageFetchedResultsController;//推送消息数据监听
    RBQFetchedResultsController *_sigRuleFetchedResultsController;//签到规则数据监听
}

@end

@implementation HomeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userManager = [UserManager manager];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    _pushMessageFetchedResultsController = [_userManager createPushMessagesFetchedResultsController];
    _pushMessageFetchedResultsController.delegate = self;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    //创建头部数据视图
    CGFloat topViewHeight = 32 + MAIN_SCREEN_WIDTH / 2.f;
    _homeListTopView = [[HomeListTopView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, topViewHeight)];
    _homeListTopView.delegate = self;
    [_scrollView addSubview:_homeListTopView];
    //创建底部按钮视图
    CGFloat bottomViewHeight = MAIN_SCREEN_WIDTH / 2;
    _homeListBottomView = [[HomeListBottomView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_homeListTopView.frame), MAIN_SCREEN_WIDTH, bottomViewHeight)];
    _homeListBottomView.delegate = self;
    [_scrollView addSubview:_homeListBottomView];
    _scrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH, CGRectGetMaxY(_homeListBottomView.frame));
    [self.view addSubview:_scrollView];
    [self setLeftNavigationBarItem];
    [self setRightNavigationBarItem];
    //在这里统一获取一些必须获取的值
    [self getNeedValueFormNet];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.frostedViewController.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor homeListColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
}
- (void)getNeedValueFormNet {
    //从服务器获取一次规则
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
        [_userManager addSiginRuleNotfition];
    }];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if(controller == _pushMessageFetchedResultsController) {
        UILabel *label = [_rightNavigationBarButton viewWithTag:1001];
        int count = 0;
        for (PushMessage *push in controller.fetchedObjects) {
            if(push.unread == YES)
                count ++;
        }
        label.backgroundColor = [UIColor redColor];
        if(count)
            label.text = [NSString stringWithFormat:@"%d",count];
        else {
            label.text = nil;
            label.backgroundColor = [UIColor clearColor];
        }
    } else {
        User *user = controller.fetchedObjects[0];
        UIImageView *imageView = [_leftNavigationBarButton viewWithTag:1001];
        UILabel *nameLabel = [_leftNavigationBarButton viewWithTag:1002];
        UILabel *companyLabel = [_leftNavigationBarButton viewWithTag:1003];
        [imageView sd_setImageWithURL:[NSURL URLWithString:user.currCompany.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        nameLabel.text = user.real_name;
        if([NSString isBlank:user.currCompany.company_name])
            companyLabel.text = @"未选择圈子";
        else {
            companyLabel.text = user.currCompany.company_name;
            //圈子变了 就要获取一次对应圈子的签到规则
            //从服务器获取一次规则
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
                [_userManager addSiginRuleNotfition];
            }];
        }
    }
}
#pragma mark -- 
#pragma mark -- HomeListTopDelegate 
//需要选择圈子后才能操作
- (void)executeNeedSelectCompany:(void (^)(void))aBlock
{
    if(_userManager.user.currCompany.company_no == 0) {
        [self.navigationController.view showMessageTips:@"请选择一个圈子后再进行此操作"];
    } else {
        aBlock();
    }
}
//今天完成日程被点击
- (void)todayFinishCalendar {
    CalendarController *calendar = [CalendarController new];
    calendar.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:calendar animated:YES];
}
//本周完成日程被点击
- (void)weekFinishCalendar {
    CalendarController *calendar = [CalendarController new];
    calendar.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:calendar animated:YES];
}
//我委派的任务被点击
- (void)createTaskClicked {
    [self executeNeedSelectCompany:^{
        TaskListController *list = [TaskListController new];
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    }];
}
//我负责的任务被点击
- (void)chargeTaskClicked {
    [self executeNeedSelectCompany:^{
        TaskListController *list = [TaskListController new];
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    }];
}
#pragma mark -- 
#pragma mark -- HomeListBottomDelegate
//第几个按钮被点击了
- (void)homeListBottomClicked:(NSInteger)index {
    if(index == 0) {//公告
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Notice?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 1) {//动态
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Dynamic?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 2) {//签到
        [self executeNeedSelectCompany:^{
            SiginController *sigin = [SiginController new];
            sigin.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:sigin animated:YES]; 
        }];
    } else if(index == 3) {//审批
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@ApprovalByFormBuilder?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 4) {//邮件
        [self.navigationController.view showMessageTips:@"开发中，敬请期待！"];
    } else if (index == 5) {//会议
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@meeting?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if (index == 6) {//投票
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Vote?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else {//通用审批
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Approval?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,[UserManager manager].user.user_guid,[UserManager manager].user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    }
}
#pragma mark --
#pragma mark -- setNavigationBar
- (void)setLeftNavigationBarItem {
    User *user = _userManager.user;
    _leftNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftNavigationBarButton.frame = CGRectMake(0, 0, 100, 28);
    //创建头像
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 33, 33)];
    imageView.layer.cornerRadius = 33 / 2.f;
    imageView.clipsToBounds = YES;
    imageView.tag = 1001;
    [imageView sd_setImageWithURL:[NSURL URLWithString:user.currCompany.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    [_leftNavigationBarButton addSubview:imageView];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 2, 100, 12)];
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = user.real_name;
    nameLabel.tag = 1002;
    [_leftNavigationBarButton addSubview:nameLabel];
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 23, 100, 10)];
    companyLabel.font = [UIFont systemFontOfSize:10];
    companyLabel.textColor = [UIColor whiteColor];
    if([NSString isBlank:user.currCompany.company_name])
        companyLabel.text = @"未选择圈子";
    else
        companyLabel.text = user.currCompany.company_name;
    companyLabel.tag = 1003;
    [_leftNavigationBarButton addSubview:companyLabel];
    [_leftNavigationBarButton addTarget:self action:@selector(leftNavigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftNavigationBarButton];
}
- (void)leftNavigationBtnClicked:(id)btn {
    [self.navigationController.frostedViewController presentMenuViewController];
}
- (void)setRightNavigationBarItem {
    _rightNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightNavigationBarButton.frame = CGRectMake(0, 0, 40, 40);
    [_rightNavigationBarButton setImage:[UIImage imageNamed:@"home_remind_icon"] forState:UIControlStateNormal];
    [_rightNavigationBarButton addTarget:self action:@selector(rightNavigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _rightNavigationBarButton.clipsToBounds = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavigationBarButton];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, -5, 15, 15)];
    int count = 0;
    for (PushMessage *push in [_userManager getPushMessageArr]) {
        if(push.unread == YES)
            count ++;
    }
    label.backgroundColor = [UIColor redColor];
    if(count)
        label.text = [NSString stringWithFormat:@"%d",count];
    else {
        label.text = nil;
        label.backgroundColor = [UIColor clearColor];
    }
    label.layer.cornerRadius = 7.5;
    label.clipsToBounds = YES;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 1001;
    [_rightNavigationBarButton addSubview:label];
}
- (void)rightNavigationBtnClicked:(UIButton*)item {
    PushMessageController *view = [PushMessageController new];
    view.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:view animated:YES];
}
@end
