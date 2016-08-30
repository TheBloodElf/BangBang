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
#import "PushMessageController.h"
#import "UserHttp.h"

#import "HomeListOpertion.h"

@interface HomeListController () {
    UIScrollView *_scrollView;//整体的滚动视图
    HomeListTopView *_homeListTopView;//头部数据视图
    HomeListBottomView *_homeListBottomView;//底部的按钮视图
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据库监听
    RBQFetchedResultsController *_pushMessageFetchedResultsController;//推送消息数据监听
    
    HomeListOpertion *_homeListOpertion;
}

@end

@implementation HomeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    _homeListOpertion = [HomeListOpertion new];
    _homeListOpertion.homeListController = self;
    [_homeListOpertion startConnect];
    //创建数据监听
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.data = @"userFetchedResultsController";
    _userFetchedResultsController.delegate = _homeListOpertion;
    _pushMessageFetchedResultsController = [_userManager createPushMessagesFetchedResultsController];
    _pushMessageFetchedResultsController.delegate = _homeListOpertion;
    _pushMessageFetchedResultsController.data = @"pushMessageFetchedResultsController";
    //创建界面
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.showsVerticalScrollIndicator = NO;
    //创建头部数据视图
    CGFloat topViewHeight = 32 + MAIN_SCREEN_WIDTH / 2.f;
    _homeListTopView = [[HomeListTopView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, topViewHeight)];
    _homeListTopView.delegate = _homeListOpertion;
    [_scrollView addSubview:_homeListTopView];
    //创建底部按钮视图
    CGFloat bottomViewHeight = MAIN_SCREEN_WIDTH / 2;
    _homeListBottomView = [[HomeListBottomView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_homeListTopView.frame), MAIN_SCREEN_WIDTH, bottomViewHeight)];
    _homeListBottomView.delegate = _homeListOpertion;
    [_scrollView addSubview:_homeListBottomView];
    _scrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH, CGRectGetMaxY(_homeListBottomView.frame));
    [self.view addSubview:_scrollView];
    //加上左边边界侧滑手势
    UIScreenEdgePanGestureRecognizer * screenEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftClicked:)];
    screenEdgePanGesture.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:screenEdgePanGesture];
    [self setLeftNavigationBarItem];
    [self setRightNavigationBarItem];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor homeListColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)showLeftClicked:(UIScreenEdgePanGestureRecognizer*)sepr {
    [self.navigationController.frostedViewController presentMenuViewController];
}
#pragma mark --
#pragma mark -- setNavigationBar
- (void)setLeftNavigationBarItem {
    User *user = _userManager.user;
    _leftNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftNavigationBarButton.frame = CGRectMake(0, 0, 100, 28);
    //创建头像
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 33, 33)];
    [imageView zy_cornerRadiusRoundingRect];
    imageView.tag = 1001;
    [imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    [_leftNavigationBarButton addSubview:imageView];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 2, 100, 12)];
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = user.real_name;
    nameLabel.tag = 1002;
    [_leftNavigationBarButton addSubview:nameLabel];
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 23, 100, 10)];
    companyLabel.font = [UIFont systemFontOfSize:10];
    companyLabel.textColor = [UIColor whiteColor];
    if([NSString isBlank:user.currCompany.company_name])
        companyLabel.text = @"未选择圈子";
    else
        companyLabel.text = user.currCompany.company_name;
    companyLabel.tag = 1003;
    [_leftNavigationBarButton addSubview:companyLabel];
    [_leftNavigationBarButton addTarget:self action:@selector(leftNavigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftNavigationBarButton];
}
- (void)leftNavigationBtnClicked:(id)btn {
    [self.navigationController.frostedViewController presentMenuViewController];
}
- (void)setRightNavigationBarItem {
    _rightNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightNavigationBarButton.frame = CGRectMake(0, 0, 40, 40);
    [_rightNavigationBarButton setImage:[UIImage imageNamed:@"home_remind_icon"] forState:UIControlStateNormal];
    [_rightNavigationBarButton addTarget:self action:@selector(rightNavigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _rightNavigationBarButton.clipsToBounds = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavigationBarButton];
    PPDragDropBadgeView *label = [[PPDragDropBadgeView alloc] initWithFrame:CGRectMake(20, -5, 15, 15)];
    int count = 0;
    for (PushMessage *push in [_userManager getPushMessageArr]) {
        if(push.unread == YES)
            count ++;
    }
    label.text = [NSString stringWithFormat:@"%d",count];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10];
    label.tag = 1001;
    [_rightNavigationBarButton addSubview:label];
}
- (void)rightNavigationBtnClicked:(UIButton*)item {
    PushMessageController *view = [PushMessageController new];
    view.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:view animated:YES];
}
@end
