//
//  BusinessController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "BusinessController.h"
#import "REFrostedViewController.h"
#import "LeftMenuController.h"
#import "TabBarController.h"

@interface BusinessController () {
    UINavigationController *_businessNav;//这个导航用于弹出通知信息，所以多了这一层
    REFrostedViewController *_rEFrostedView;//侧滑控制器
}
@end

@implementation BusinessController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //创建界面
    _rEFrostedView = [[REFrostedViewController alloc] initWithContentViewController:[TabBarController new] menuViewController:[LeftMenuController new]];
    _rEFrostedView.direction = REFrostedViewControllerDirectionLeft;
    _rEFrostedView.menuViewSize = CGSizeMake(MAIN_SCREEN_WIDTH*3/4, MAIN_SCREEN_HEIGHT + 44);
    _rEFrostedView.liveBlur = YES;
    //创建业务根视图控制器
    _businessNav = [[UINavigationController alloc] initWithRootViewController:_rEFrostedView];
    [self addChildViewController:_businessNav];
    [_businessNav.view willMoveToSuperview:self.view];
    [_businessNav willMoveToParentViewController:self];
    [_businessNav setNavigationBarHidden:YES animated:YES];
    [self.view addSubview:_businessNav.view];
    //加上新消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecivePushMessage:) name:@"DidRecivePushMessage" object:nil];
    // Do any additional setup after loading the view.
}
//在这里统一处理弹窗
- (void)didRecivePushMessage:(NSNotification*)noti {
    
    [_businessNav pushViewController:[UIViewController new] animated:YES];
}
@end
