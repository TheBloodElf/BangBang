//
//  HomeListController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HomeListController.h"
#import "HomeListTopView.h"
#import "HomeListBottomView.h"
#import "UserManager.h"

@interface HomeListController ()<HomeListTopDelegate,HomeListBottomDelegate> {
    UIScrollView *_scrollView;//整体的滚动视图
    HomeListTopView *_homeListTopView;//头部数据视图
    HomeListBottomView *_homeListBottomView;//底部的按钮视图
    UIButton *_leftNavigationBarButton;//左边导航的按钮
    UIButton *_rightNavigationBarButton;//右边导航的按钮
}

@end

@implementation HomeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    //创建头部数据视图
    CGFloat topViewHeight = 32 + MAIN_SCREEN_WIDTH / 2;
    _homeListTopView = [[HomeListTopView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, topViewHeight)];
    _homeListTopView.delegate = self;
    [_scrollView addSubview:_homeListTopView];
    //创建底部按钮视图
    CGFloat bottomViewHeight = MAIN_SCREEN_WIDTH / 2;
    _homeListBottomView = [[HomeListBottomView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_homeListTopView.frame), MAIN_SCREEN_WIDTH, bottomViewHeight)];
    _homeListBottomView.delegate = self;
    [_scrollView addSubview:_homeListBottomView];
    _scrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH, CGRectGetMaxY(_homeListBottomView.frame));
    [self.view addSubview:_scrollView];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
#pragma mark -- 
#pragma mark -- HomeListTopDelegate 
//今天完成日程被点击
- (void)todayFinishCalendar {
    
}
//本周完成日程被点击
- (void)weekFinishCalendar {
    
}
//我委派的任务被点击
- (void)createTaskClicked {
    
}
//我负责的任务被点击
- (void)chargeTaskClicked {
    
}
#pragma mark -- 
#pragma mark -- HomeListBottomDelegate
//第几个按钮被点击了
- (void)homeListBottomClicked:(NSInteger)index {
    if(index == 0) {
        
    } else if (index == 1) {
        
    }
}
#pragma mark --
#pragma mark -- setNavigationBar
- (void)setLeftNavigationBarItem {
    _leftNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftNavigationBarButton.frame = CGRectMake(0, 0, 100, 38);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 33, 33)];
    imageView.layer.cornerRadius = 33 / 2.f;
    imageView.clipsToBounds = YES;
    UserManager *manager = [UserManager manager];
    User *user = manager.user;
    
}

@end
