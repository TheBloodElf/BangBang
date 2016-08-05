//
//  LoginController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "LoginController.h"
#import "UserLoginController.h"

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
    [_loginNavigationVC setNavigationBarHidden:YES animated:YES];
    [_loginNavigationVC.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.view addSubview:_loginNavigationVC.view];
    [_loginNavigationVC.view willMoveToSuperview:self.view];
    [self addChildViewController:_loginNavigationVC];
    [_loginNavigationVC willMoveToParentViewController:self];
    // Do any additional setup after loading the view.
}

@end
