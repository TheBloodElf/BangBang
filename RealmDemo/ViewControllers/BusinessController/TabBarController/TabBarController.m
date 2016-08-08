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
#import "MoreViewController.h"
#import "XAddrBookController.h"
#import "UserManager.h"

#import "CalendarCreateController.h"
#import "TaskCreateController.h"
#import "CreateMeetingController.h"
#import "BushSearchViewController.h"

@interface TabBarController ()<UITabBarControllerDelegate,MoreViewControllerDelegate> {
    UITabBarController *_tabBarVC;
}

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tabBarVC = [UITabBarController new];
    _tabBarVC.viewControllers = @[[self homeListController],[self messageController],[self viewController],[self xAddrBookController],[self mineViewController]];
    _tabBarVC.delegate = self;
    [self addChildViewController:_tabBarVC];
    [self.view addSubview:_tabBarVC.view];
}
#pragma mark -- UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if([viewController isMemberOfClass:[UIViewController class]]) {
        //在这里加上一个选择视图控制器
        MoreViewController *more = [MoreViewController new];
        more.view.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
        more.delegate = self;
        [self addChildViewController:more];
        [self.view addSubview:more.view];
        return NO;
    }
    return YES;
}
//需要选择圈子后才能操作
- (void)executeNeedSelectCompany:(void (^)(void))aBlock
{
    if([UserManager manager].user.currCompany.company_no == 0) {
        [self.navigationController.view showMessageTips:@"请选择一个圈子后再进行此操作"];
    } else {
        aBlock();
    }
}
//这里写回调 用REFrostedViewController push 
#pragma mark -- MoreViewControllerDelegate
- (void)MoreViewDidClicked:(int)index {
    if(index == 0) {//创建日程
        [self.navigationController pushViewController:[CalendarCreateController new] animated:YES];
    } else if (index == 1) {//创建任务
        [self executeNeedSelectCompany:^{
            [self.navigationController pushViewController:[TaskCreateController new] animated:YES];
        }];
    } else if (index == 2) {//创建会议
        [self executeNeedSelectCompany:^{
            [self.navigationController pushViewController:[CreateMeetingController new] animated:YES];
        }];
    } else {//加入圈子
        [self.navigationController pushViewController:[BushSearchViewController new] animated:YES];
    }
}
- (UINavigationController*)homeListController {
    HomeListController *home = [HomeListController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"首页";
    nav.navigationBar.translucent = NO;
    nav.tabBarItem.image = [[UIImage imageNamed:@"index-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"index-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
- (UINavigationController*)xAddrBookController {
    XAddrBookController *home = [XAddrBookController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"联系人";
    nav.navigationBar.translucent = NO;
    nav.tabBarItem.image = [[UIImage imageNamed:@"set-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"set-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
- (UIViewController*)viewController {
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
    nav.tabBarItem.image = [[UIImage imageNamed:@"message-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"message-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}
- (UINavigationController*)mineViewController {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MineView" bundle:nil];
    MineViewController *home = [story instantiateViewControllerWithIdentifier:@"MineViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    nav.tabBarItem.title = @"我的";
    nav.navigationBar.translucent = NO;
    nav.tabBarItem.image = [[UIImage imageNamed:@"contact-gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [[UIImage imageNamed:@"contact-green"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return nav;
}

@end
