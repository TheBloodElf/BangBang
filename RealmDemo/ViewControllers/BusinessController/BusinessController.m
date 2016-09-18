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

@interface BusinessController () {
    UINavigationController *_businessNav;
}

@end

@implementation BusinessController

- (void)viewDidLoad {
    [super viewDidLoad];
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
}

@end
