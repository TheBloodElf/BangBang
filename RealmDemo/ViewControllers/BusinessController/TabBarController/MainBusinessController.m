//
//  TabBarController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MainBusinessController.h"
#import "HomeListController.h"
#import "MessageController.h"
#import "XAddrBookController.h"
#import "MainBusinessOpertion.h"

@interface MainBusinessController () {
    UITabBarController *_tabBarVC;
    MainBusinessOpertion *_mainBusinessOpertion;
}

@end

@implementation MainBusinessController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainBusinessOpertion = [MainBusinessOpertion new];
    _mainBusinessOpertion.mainBusinessController = self;
    [_mainBusinessOpertion startConnect];
    //创建界面
    _tabBarVC = [UITabBarController new];
    _tabBarVC.viewControllers = @[[self homeListController],[self messageController],[self centerController],[self xAddrBookController],[self mineViewController]];
    _tabBarVC.delegate = _mainBusinessOpertion;
    [self addChildViewController:_tabBarVC];
    [self.view addSubview:_tabBarVC.view];
}
- (UINavigationController*)homeListController {
    HomeListController *home = [HomeListController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"首页";
    nav.navigationBar.translucent = NO;
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} forState:UIControlStateSelected];
    nav.tabBarItem.image = [[UIImage imageNamed:@"index-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"index-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
- (UINavigationController*)xAddrBookController {
    XAddrBookController *home = [XAddrBookController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"联系人";
    nav.navigationBar.translucent = NO;
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} forState:UIControlStateSelected];
    nav.tabBarItem.image = [[UIImage imageNamed:@"set-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"set-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
- (UIViewController*)centerController {
    UIViewController *view = [UIViewController new];
    view.tabBarItem.image = [[UIImage imageNamed:@"home_add"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    view.tabBarItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    return view;
}
- (UINavigationController*)messageController {
    MessageController *home = [MessageController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"消息";
    nav.navigationBar.translucent = NO;
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} forState:UIControlStateSelected];
    nav.tabBarItem.image = [[UIImage imageNamed:@"message-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"message-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
- (UINavigationController*)mineViewController {
    UIViewController *home = [ViewControllerGenerator getViewController:@"MineViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"我的";
    nav.navigationBar.translucent = NO;
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor grayColor]} forState:UIControlStateNormal];
    [nav.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1]} forState:UIControlStateSelected];
    nav.tabBarItem.image = [[UIImage imageNamed:@"contact-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"contact-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
@end
