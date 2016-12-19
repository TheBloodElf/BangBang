//
//  AppListController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AppListController.h"
#import "MyAppView.h"
#import "AppCenterView.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "LocalUserApp.h"
#import "IdentityManager.h"
#import "WebNonstandarViewController.h"
#import "SiginController.h"

@interface AppListController ()<MyAppDelegate,AppCenterDelegate> {
    MyAppView *_myAppView;
    AppCenterView *_appCenterView;
    UserManager *_userManager;
    BOOL _isFirst;
}

@property (weak,   nonatomic) IBOutlet NSLayoutConstraint *viewLeft;
@property (weak,   nonatomic) IBOutlet UIScrollView *bootomScrollView;
@property (nonatomic, assign) BOOL isEditStatue;//是不是编辑状态

@end

@implementation AppListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"应用中心";
    _userManager = [UserManager manager];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editChangeClicked:)];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_isFirst) return;
    _isFirst = YES;
    
    _myAppView = [[MyAppView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 36)];
    _myAppView.delegate = self;
    _appCenterView = [[AppCenterView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 36)];
    _appCenterView.delegate = self;
    [self.bootomScrollView addSubview:_appCenterView];
    [self.bootomScrollView addSubview:_myAppView];
}
- (void)editChangeClicked:(UIBarButtonItem*)item {
    self.isEditStatue = !self.isEditStatue;
    if(self.isEditStatue == YES) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editChangeClicked:)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editChangeClicked:)];
    }
    _appCenterView.isEditStatue = self.isEditStatue;
    _myAppView.isEditStatue = self.isEditStatue;
    [_appCenterView reloadCollentionView];
    [_myAppView reloadCollentionView];
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
#pragma mark -- AppCenterDelegate
- (void)appCenterAddApp:(UserApp*)app {
    [self.navigationController.view showLoadingTips:@""];
    [UserHttp addApp:_userManager.user.user_guid appGuid:app.app_guid handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        [_userManager addUserApp:app];
    }];
}
- (void)appCenterDelApp:(UserApp*)app {
    [self.navigationController.view showLoadingTips:@""];
    [UserHttp deleteApp:_userManager.user.user_guid appGuid:app.app_guid handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        for (UserApp *userApp in [_userManager getUserAppArr]) {
            if([userApp.app_guid isEqualToString:app.app_guid]) {
                 [_userManager delUserApp:userApp];
                break;
            }
        }
    }];
}
#pragma mark -- MyAppDelegate
- (void)MyAppViewAddApp {
    UIButton *myApp = [self.view viewWithTag:1000];
    UIButton *appCenter = [self.view viewWithTag:1001];
    myApp.selected = NO;
    appCenter.selected = YES;
    self.viewLeft.constant = MAIN_SCREEN_WIDTH / 2.f;
    [self.bootomScrollView setContentOffset:CGPointMake(MAIN_SCREEN_WIDTH, 0) animated:NO];
}
- (void)MyAppViewDeleteApp:(UserApp*)userApp {
    [self.navigationController.view showLoadingTips:@""];
    [UserHttp deleteApp:_userManager.user.user_guid appGuid:userApp.app_guid handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        for (UserApp *tempApp in [_userManager getUserAppArr]) {
            if([tempApp.app_guid isEqualToString:userApp.app_guid]) {
                [_userManager delUserApp:tempApp];
                break;
            }
        }
    }];
}
- (void)MyAppLocalAppSelect:(LocalUserApp*)localUserApp {
    if([localUserApp.titleName isEqualToString:@"公告"]) {//公告
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Notice?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if ([localUserApp.titleName isEqualToString:@"动态"]) {//动态
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Dynamic?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if ([localUserApp.titleName isEqualToString:@"签到"]) {//签到
        [self executeNeedSelectCompany:^{
            SiginController *sigin = [SiginController new];
            sigin.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:sigin animated:YES];
        }];
    } else if([localUserApp.titleName isEqualToString:@"审批"]) {//审批
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@ApprovalByFormBuilder?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if ([localUserApp.titleName isEqualToString:@"帮邮"]) {//邮件 调用手机上的邮件
        //适配iOS10
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0f) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"] options:@{} completionHandler:^(BOOL success) {
            }];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"]];
        }
    } else if ([localUserApp.titleName isEqualToString:@"会议"]) {//会议
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@meeting?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    } else if([localUserApp.titleName isEqualToString:@"投票"]){//投票
        [self executeNeedSelectCompany:^{
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
            NSString *str = [NSString stringWithFormat:@"%@Vote?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.applicationUrl = str;
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [[self navigationController] pushViewController:webViewcontroller animated:YES];
        }];
    }
}
- (void)MyAppNetAppSelect:(UserApp*)userApp {
    WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc] init];
    webViewcontroller.applicationUrl = userApp.app_url;
    webViewcontroller.hidesBottomBarWhenPushed = YES;
    webViewcontroller.showNavigationBar = YES;
    [[self navigationController] pushViewController:webViewcontroller animated:YES];
}
- (IBAction)btnClicked:(UIButton*)sender {
    UIButton *myApp = [self.view viewWithTag:1000];
    UIButton *appCenter = [self.view viewWithTag:1001];
    myApp.selected = NO;
    appCenter.selected = NO;
    if([sender.currentTitle isEqualToString:@"我的应用"]) {
        self.viewLeft.constant = 0;
        [self.bootomScrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    else {
        self.viewLeft.constant = MAIN_SCREEN_WIDTH / 2.f;
        [self.bootomScrollView setContentOffset:CGPointMake(MAIN_SCREEN_WIDTH, 0) animated:NO];
    }
    sender.selected = YES;
}
@end
