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

@interface HomeListController ()<HomeListTopDelegate,HomeListBottomDelegate,RBQFetchedResultsControllerDelegate> {
    UIScrollView *_scrollView;//整体的滚动视图
    HomeListTopView *_homeListTopView;//头部数据视图
    HomeListBottomView *_homeListBottomView;//底部的按钮视图
    UIButton *_leftNavigationBarButton;//左边导航的按钮
    UIButton *_rightNavigationBarButton;//右边导航的按钮
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据库监听
    RBQFetchedResultsController *_pushMessageFetchedResultsController;//推送消息数据监听
}

@end

@implementation HomeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    _pushMessageFetchedResultsController = [_userManager createPushMessagesFetchedResultsController];
    _pushMessageFetchedResultsController.delegate = self;
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
    [self setLeftNavigationBarItem];
    [self setRightNavigationBarItem];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.frostedViewController.navigationController setNavigationBarHidden:YES animated:YES];
}
#pragma mark -- 
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if(controller == _pushMessageFetchedResultsController) {
        UILabel *label = [_rightNavigationBarButton viewWithTag:1001];
        int count = 0;
        for (PushMessage *push in controller.fetchedObjects) {
            if(push.unread == YES)
                count ++;
        }
        if(count )
            label.text = [NSString stringWithFormat:@"%d",count];
        else
            label.text = nil;
    } else {
        User *user = controller.fetchedObjects[0];
        UIImageView *imageView = [_leftNavigationBarButton viewWithTag:1001];
        UILabel *nameLabel = [_leftNavigationBarButton viewWithTag:1002];
        UILabel *companyLabel = [_leftNavigationBarButton viewWithTag:1003];
        [imageView sd_setImageWithURL:[NSURL URLWithString:user.currCompany.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        nameLabel.text = user.real_name;
        companyLabel.text = user.currCompany.company_name;
    }
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
    User *user = _userManager.user;
    _leftNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftNavigationBarButton.frame = CGRectMake(0, 0, 100, 38);
    //创建头像
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 33, 33)];
    imageView.layer.cornerRadius = 33 / 2.f;
    imageView.clipsToBounds = YES;
    imageView.tag = 1001;
    [imageView sd_setImageWithURL:[NSURL URLWithString:user.currCompany.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    [_leftNavigationBarButton addSubview:imageView];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 2, 100, 12)];
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text = user.real_name;
    nameLabel.tag = 1002;
    [_leftNavigationBarButton addSubview:nameLabel];
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 23, 100, 10)];
    companyLabel.font = [UIFont systemFontOfSize:10];
    companyLabel.textColor = [UIColor blackColor];
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
    [_rightNavigationBarButton setImage:[UIImage imageNamed:@"pushMessage_Email1"] forState:UIControlStateNormal];
    [_rightNavigationBarButton addTarget:self action:@selector(rightNavigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _rightNavigationBarButton.clipsToBounds = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightNavigationBarButton];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, -5, 20, 15)];
    int count = 0;
    for (PushMessage *push in [_userManager getPushMessageArr]) {
        if(push.unread == YES)
            count ++;
    }
    if(count )
        label.text = [NSString stringWithFormat:@"%d",count];
    else
        label.text = nil;
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentLeft;
    label.tag = 1001;
    [_rightNavigationBarButton addSubview:label];
}
- (void)rightNavigationBtnClicked:(UIButton*)item {
    PushMessageController *push = [PushMessageController new];
    push.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:push animated:YES];
}
@end
