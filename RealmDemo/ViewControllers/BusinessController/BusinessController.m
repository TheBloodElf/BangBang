//
//  BusinessController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "BusinessController.h"
#import "REFrostedViewController.h"

@implementation BusinessController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //创建界面
    REFrostedViewController *_rEFrostedView = [[REFrostedViewController alloc] initWithContentViewController:[ViewControllerGenerator getViewController:@"MainBusinessController" parameters:@{}] menuViewController:[ViewControllerGenerator getViewController:@"LeftMenuController" parameters:@{}]];
    //这个导航用于弹出通知信息，是业务模块的根控制器
    UINavigationController *businessNav = [[UINavigationController alloc] initWithRootViewController:_rEFrostedView];
    [self addChildViewController:businessNav];
    [businessNav.view willMoveToSuperview:self.view];
    [businessNav willMoveToParentViewController:self];
    [businessNav setNavigationBarHidden:YES animated:YES];
    businessNav.navigationBar.translucent = NO;
    businessNav.navigationBar.barTintColor = [UIColor colorWithRed:8/255.f green:21/255.f blue:63/255.f alpha:1];
    [self.view addSubview:businessNav.view];
}
@end
