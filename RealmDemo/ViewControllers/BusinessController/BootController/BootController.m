//
//  BootController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/10/8.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "BootController.h"
#import "REFrostedViewController.h"
#import "BushManageViewController.h"
#import "MoreSelectView.h"

@interface BootController () {
    UIScrollView *_scrollView;//引导页的所有图片滚动视图
}

@end

@implementation BootController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    //背景模糊
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.alpha = 0.2;
    effectView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
    [self.view addSubview:effectView];
    //引导滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    _scrollView.scrollEnabled = NO;
    [_scrollView addSubview:[self showComanyView]];
    [_scrollView addSubview:[self leftSlideView]];
    [_scrollView addSubview:[self myCenterView]];
    [_scrollView addSubview:[self clickedCompanyView]];
    [_scrollView addSubview:[self clickedMoreView]];
    [self.view addSubview:_scrollView];
    //跳过
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(10 ,MAIN_SCREEN_HEIGHT - 50, 50, 30);
    [btn setTitle:@"跳过" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(jumpClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
//跳过引导
- (void)jumpClicked:(UIButton*)btn {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BootOfUserFinish" object:nil];
}
//显示新的引导页
- (void)showNextBootView {
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + _scrollView.frame.size.width, 0) animated:NO];
}
//展示所有圈子
- (UIView *)showComanyView {
    UIView *showCompany = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    //响应区域
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    showBtn.frame = CGRectMake(10, 20, 50, 50);
    [showBtn addTarget:self action:@selector(showCompany:) forControlEvents:UIControlEventTouchUpInside];
    [showCompany addSubview:showBtn];
    //用户提示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60, 25, MAIN_SCREEN_WIDTH - 60, 50)];
    label.text = @"点击头像出现全部圈子";
    label.textColor = [UIColor redColor];
    [showCompany addSubview:label];
    return showCompany;
}
- (void)showCompany:(UIButton*)btn {
    //得到侧滑菜单控制器
    UINavigationController *navigationController = self.parentViewController.childViewControllers[0];
    REFrostedViewController *frosendController = navigationController.viewControllers[0];
    [frosendController presentMenuViewController];
    [self showNextBootView];
}
//左滑返回首页
- (UIView *)leftSlideView {
    UIView *leftSlide = [[UIView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    //响应区域
    UISwipeGestureRecognizer *swipeGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideCompany:)];
    swipeGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftSlide addGestureRecognizer:swipeGR];
    //用户提示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.5 * (MAIN_SCREEN_HEIGHT - 50), MAIN_SCREEN_WIDTH, 50)];
    label.text = @"左滑返回首页";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor redColor];
    [leftSlide addSubview:label];
    return leftSlide;
}
- (void)hideCompany:(UISwipeGestureRecognizer*)sgr {
    //得到侧滑菜单控制器
    UINavigationController *navigationController = self.parentViewController.childViewControllers[0];
    REFrostedViewController *frosendController = navigationController.viewControllers[0];
    [frosendController hideMenuViewController];
    [self showNextBootView];
}
//进入我的界面
- (UIView*)myCenterView {
    UIView *myCenter = [[UIView alloc] initWithFrame:CGRectMake(2 * MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    //用户提示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, MAIN_SCREEN_WIDTH, 50)];
    label.text = @"加圈子";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor redColor];
    [myCenter addSubview:label];
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 64, MAIN_SCREEN_WIDTH - 64, 64)];
    myLabel.textAlignment = NSTextAlignmentRight;
    myLabel.text = @"step1：点击我的";
    myLabel.textColor = [UIColor redColor];
    [myCenter addSubview:myLabel];
    //响应区域
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    showBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH - 100, MAIN_SCREEN_HEIGHT - 64, 100, 64);
    [showBtn addTarget:self action:@selector(toMyCenter:) forControlEvents:UIControlEventTouchUpInside];
    [myCenter addSubview:showBtn];
    return myCenter;
}
- (void)toMyCenter:(UIButton*)btn {
    //得到tabbatcontroller
    UINavigationController *navigationController = self.parentViewController.childViewControllers[0];
    REFrostedViewController *frosendController = navigationController.viewControllers[0];
    UITabBarController *tabBarController = frosendController.contentViewController.childViewControllers[0];
    [tabBarController setSelectedIndex:4];
    [self showNextBootView];
}
//点击我的圈子
- (UIView*)clickedCompanyView {
    UIView *clickedCompany = [[UIView alloc] initWithFrame:CGRectMake(3 * MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    //响应区域
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    showBtn.frame = CGRectMake(0, 220, MAIN_SCREEN_WIDTH, 44);
    [showBtn addTarget:self action:@selector(toMyCompany:) forControlEvents:UIControlEventTouchUpInside];
    [clickedCompany addSubview:showBtn];
    //用户提示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, MAIN_SCREEN_WIDTH, 50)];
    label.text = @"加圈子";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor redColor];
    [clickedCompany addSubview:label];
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, MAIN_SCREEN_WIDTH, 44)];
    myLabel.textAlignment = NSTextAlignmentRight;
    myLabel.text = @"step2：点击我的圈子";
    myLabel.textColor = [UIColor redColor];
    [clickedCompany addSubview:myLabel];
    return clickedCompany;
}
- (void)toMyCompany:(UIButton*)btn {
    //得到tabbatcontroller
    UINavigationController *navigationController = self.parentViewController.childViewControllers[0];
    REFrostedViewController *frosendController = navigationController.viewControllers[0];
    UITabBarController *tabBarController = frosendController.contentViewController.childViewControllers[0];
    UINavigationController *navigationCon = tabBarController.selectedViewController;
    [navigationCon pushViewController:[BushManageViewController new] animated:YES];
    [self showNextBootView];
}
//点击更多
- (UIView*)clickedMoreView {
    UIView *clickedMore = [[UIView alloc] initWithFrame:CGRectMake(4 * MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    //响应区域
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    showBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH - 64, 0, 64, 64);
    [showBtn addTarget:self action:@selector(clickedMore:) forControlEvents:UIControlEventTouchUpInside];
    [clickedMore addSubview:showBtn];
    //用户提示
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, MAIN_SCREEN_WIDTH, 50)];
    label.text = @"加圈子";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor redColor];
    [clickedMore addSubview:label];
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 44)];
    myLabel.textAlignment = NSTextAlignmentRight;
    myLabel.text = @"step3：点击更多";
    myLabel.textColor = [UIColor redColor];
    [clickedMore addSubview:myLabel];
    return clickedMore;
}
- (void)clickedMore:(UIButton*)btn {
    //得到tabbatcontroller
    UINavigationController *navigationController = self.parentViewController.childViewControllers[0];
    REFrostedViewController *frosendController = navigationController.viewControllers[0];
    UITabBarController *tabBarController = frosendController.contentViewController.childViewControllers[0];
    UINavigationController *navigationCon = tabBarController.selectedViewController;
    BushManageViewController *managerController = navigationCon.viewControllers[navigationCon.viewControllers.count - 1];
    MoreSelectView *selectView = [managerController.view viewWithTag:10000];
    [selectView showSelectView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BootOfUserFinish" object:nil];
}

@end
