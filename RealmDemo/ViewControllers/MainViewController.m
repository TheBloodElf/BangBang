//
//  MainViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MainViewController.h"
#import "BusinessController.h"
#import "LoginController.h"
#import "WelcomeController.h"
#import "IdentityManager.h"
#import "UserManager.h"

@interface MainViewController () {
    WelcomeController *_welcome;//欢迎界面
    LoginController *_login;//登录界面
    BusinessController *_business;//业务界面
}
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //从本地读取登录信息
    IdentityManager *manager = [IdentityManager manager];
    [manager readAuthorizeData];
    self.view.backgroundColor = [UIColor whiteColor];
    //进入判断逻辑
    [self gotoIdentityVC];
    //加上重新登录的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogin) name:@"ShowLogin" object:nil];
    //加上欢迎界面和登录界面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(welcomeDidFinish) name:@"WelcomeDidFinish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidFinish) name:@"LoginDidFinish" object:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//弹出登录控制器
- (void)showLogin {
    IdentityManager *manager = [IdentityManager manager];
    manager.identity = [Identity new];
    [manager saveAuthorizeData];
    [self gotoIdentityVC];
}
//欢迎界面展示完毕
- (void)welcomeDidFinish {
    //设置登录信息的值
    IdentityManager *manager = [IdentityManager manager];
    manager.identity.firstUseSoft = NO;
    [manager saveAuthorizeData];
    //移除欢迎界面
    [_welcome.view removeFromSuperview];
    [_welcome removeFromParentViewController];
    //进入判断逻辑
    [self gotoIdentityVC];
}
//登录界面展示完毕
- (void)loginDidFinish {
    //移除登录界面
    [_login.view removeFromSuperview];
    [_login removeFromParentViewController];
    //进入判断逻辑
    [self gotoIdentityVC];
}
//进入判断逻辑
- (void)gotoIdentityVC {
    IdentityManager *manager = [IdentityManager manager];
    //看用户是不是第一次使用软件
    if(manager.identity.firstUseSoft) {
        _welcome = [WelcomeController new];
        [self addChildViewController:_welcome];
        [_welcome willMoveToParentViewController:self];
        [self.view addSubview:_welcome.view];
        [_welcome.view willMoveToSuperview:self.view];
    } else {
        //看用户是否登录
        if([NSString isBlank:manager.identity.user_guid]) {
            _login = [LoginController new];
            [self addChildViewController:_login];
            [_login willMoveToParentViewController:self];
            [self.view addSubview:_login.view];
            [_login.view willMoveToSuperview:self.view];
        } else {
            //已经登陆就加载登陆的用户信息
            [[UserManager manager] loadUserWithGuid:manager.identity.user_guid];
            IdentityManager * identityManager = [IdentityManager manager];
            //用融云登录聊天
            [[RYChatManager shareInstance] syncRYGroup];
            [[RCIM sharedRCIM] connectWithToken:identityManager.identity.RYToken success:nil error:nil tokenIncorrect:nil];
            _business = [BusinessController new];
            [self addChildViewController:_business];
            [_business willMoveToParentViewController:self];
            [self.view addSubview:_business.view];
            [_business.view willMoveToSuperview:self.view];
        }
    }
}
@end
