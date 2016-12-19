//
//  LoginController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "LoginController.h"
#import "UserLoginController.h"
//内部一个导航控制器，根视图控制器是UserLoginController，在UserLoginController中点击注册或者找回密码push相应界面
//登陆完成后发通知到MainViewController
@interface LoginController () {
    UINavigationController *_loginNavigationVC;//登录相关导航控制器
}

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化登录控制器
    UserLoginController *login = [UserLoginController new];
    _loginNavigationVC = [[UINavigationController alloc] initWithRootViewController:login];
    _loginNavigationVC.navigationBar.translucent = NO;
    _loginNavigationVC.navigationBar.barTintColor = [UIColor homeListColor];
    [self.view addSubview:_loginNavigationVC.view];
    [_loginNavigationVC.view willMoveToSuperview:self.view];
    [self addChildViewController:_loginNavigationVC];
    [_loginNavigationVC willMoveToParentViewController:self];
    // Do any additional setup after loading the view.
}

@end
