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
#import "GeTuiSdkManager.h"

@interface MainViewController () {
    UIViewController *_welcome;//欢迎界面
    UIViewController *_login;//登录界面
    UIViewController *_business;//业务界面
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLogin:) name:@"ShowLogin" object:nil];
    //加上欢迎界面和登录界面的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(welcomeDidFinish) name:@"WelcomeDidFinish" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginDidFinish) name:@"LoginDidFinish" object:nil];
}
//弹出登录控制器
- (void)showLogin:(NSNotification*)noti{
    //是否不需要弹窗
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
    //设置登录信息的值
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
    IdentityManager *manager = [IdentityManager manager];
    //看用户是不是第一次使用软件
    if(manager.identity.firstUseSoft) {
        _welcome = [ViewControllerGenerator getViewController:@"WelcomeController" parameters:@{}];
        _welcome.view.alpha = 0;
        [self addChildViewController:_welcome];
        [self.view addSubview:_welcome.view];
        //如果是从业务界面进来
        if([self.childViewControllers containsObject:_business]) {
            [self transitionFromViewController:_business toViewController:_welcome duration:1 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut animations:^{
                _welcome.view.alpha = 1;
                _business.view.alpha = 0;
            } completion:^(BOOL finished) {
                [_business.view removeFromSuperview];
                [_business removeFromParentViewController];
            }];
        } else {
            _welcome.view.alpha = 1;
        }
    } else {
        //看用户是否登录
        if([NSString isBlank:manager.identity.user_guid]) {
            _login = [ViewControllerGenerator getViewController:@"LoginController" parameters:@{}];
            _login.view = 0;
            [self addChildViewController:_login];
            [self.view addSubview:_login.view];
            //如果是从欢迎界面进来
            if([self.childViewControllers containsObject:_welcome]) {
                [self transitionFromViewController:_welcome toViewController:_login duration:1 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut animations:^{
                    _login.view.alpha = 1;
                    _welcome.view.alpha = 0;
                } completion:^(BOOL finished) {
                    [_welcome.view removeFromSuperview];
                    [_welcome removeFromParentViewController];
                }];
            } else if([self.childViewControllers containsObject:_business]){//如果是从业务界面进来
                [self transitionFromViewController:_business toViewController:_login duration:1 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut animations:^{
                    _login.view.alpha = 1;
                    _business.view.alpha = 0;
                } completion:^(BOOL finished) {
                    [_welcome.view removeFromSuperview];
                    [_welcome removeFromParentViewController];
                }];
            } else {
                _login.view.alpha = 1;
            }
        } else {
            //已经登陆就加载登陆的用户信息
            [[UserManager manager] loadUserWithGuid:manager.identity.user_guid];
            IdentityManager * identityManager = [IdentityManager manager];
            //初始化个推
            [[GeTuiSdkManager manager] startGeTuiSdk];
            //用融云登录聊天
            [[RYChatManager shareInstance] syncRYGroup];
            [[RCIM sharedRCIM] connectWithToken:identityManager.identity.RYToken success:nil error:nil tokenIncorrect:nil];
            _business = [ViewControllerGenerator getViewController:@"BusinessController" parameters:@{}];
            _business.view.alpha = 0;
            [self addChildViewController:_business];
            [self.view addSubview:_business.view];
            
            //如果是从登录界面进来
            if([self.childViewControllers containsObject:_login]) {
                [self transitionFromViewController:_login toViewController:_business duration:1 options:UIViewAnimationOptionTransitionNone | UIViewAnimationOptionCurveEaseInOut animations:^{
                    _business.view.alpha = 1;
                    _login.view.alpha = 0;
                } completion:^(BOOL finished) {
                    [_login.view removeFromSuperview];
                    [_login removeFromParentViewController];
                }];
            } else {
                _business.view.alpha = 1;
            }
        }
    }
}
@end
