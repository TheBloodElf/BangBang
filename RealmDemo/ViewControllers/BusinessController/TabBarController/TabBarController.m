//
//  TabBarController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TabBarController.h"
#import "HomeListController.h"
#import "MessageController.h"
#import "MineViewController.h"
#import "XAddrBookController.h"

@interface TabBarController () {
    UITabBarController *_tabBarVC;//业务控制器
}

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tabBarVC = [[UITabBarController alloc] init];
    _tabBarVC.viewControllers = @[[self homeListController],[self messageController],[self xAddrBookController],[self mineViewController]];
    [self.view addSubview:_tabBarVC.view];
    [_tabBarVC.view willMoveToSuperview:self.view];
    [self addChildViewController:_tabBarVC];
    [_tabBarVC willMoveToParentViewController:self];
    // Do any additional setup after loading the view.
}
- (UINavigationController*)homeListController {
    HomeListController *home = [HomeListController new];
    home.tabBarItem.title = @"首页";
    return [[UINavigationController alloc] initWithRootViewController:home];
}
- (UINavigationController*)messageController {
    MessageController *home = [MessageController new];
    home.tabBarItem.title = @"消息";
    return [[UINavigationController alloc] initWithRootViewController:home];
}
- (UINavigationController*)mineViewController {
    MineViewController *home = [MineViewController new];
    home.tabBarItem.title = @"联系人";
    return [[UINavigationController alloc] initWithRootViewController:home];
}
- (UINavigationController*)xAddrBookController {
    XAddrBookController *home = [XAddrBookController new];
    home.tabBarItem.title = @"设置";
    return [[UINavigationController alloc] initWithRootViewController:home];
}
@end
