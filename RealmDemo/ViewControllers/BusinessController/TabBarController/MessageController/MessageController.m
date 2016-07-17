//
//  MessageController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MessageController.h"
#import "MoreSelectView.h"
#import "MuliteSelectController.h"

@interface MessageController ()<MoreSelectViewDelegate,MuliteSelectDelegate> {
    MoreSelectView *_moreSelectView;
}

@end

@implementation MessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"会话消息";
    [self.view addSubview:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)]];
    self.view.backgroundColor = [UIColor whiteColor];
    _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 15, 64, 100, 40)];
    _moreSelectView.selectArr = @[@"发起讨论"];
    [_moreSelectView setupUI];
    _moreSelectView.delegate = self;
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.frostedViewController.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    if(_moreSelectView.isHide == YES)
        [_moreSelectView showSelectView];
    else
        [_moreSelectView hideSelectView];
}
#pragma mark -- 
#pragma mark --  MoreSelectViewDelegate
- (void)moreSelectIndex:(int)index {
    MuliteSelectController *mulite = [MuliteSelectController new];
    mulite.delegate = self;
    mulite.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mulite animated:YES];
}
#pragma mark --
#pragma mark -- MuliteSelectDelegate
- (void)muliteSelect:(NSMutableArray<Employee *> *)employeeArr {
    
}
@end
