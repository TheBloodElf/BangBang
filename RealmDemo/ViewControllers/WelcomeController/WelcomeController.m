//
//  WelcomeController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "WelcomeController.h"
#import "EAIntroViewController.h"

@interface WelcomeController ()<EAIntroViewDelegate>

@end

@implementation WelcomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    EAIntroViewController *eAintroView = [EAIntroViewController new];
    eAintroView.delegate = self;
    [self.view addSubview:eAintroView.view];
    [eAintroView.view willMoveToSuperview:self.view];
    [self addChildViewController:eAintroView];
    [eAintroView willMoveToParentViewController:self];
    // Do any additional setup after loading the view.
}
#pragma mark --
#pragma mark -- EAIntroViewDelegate 
- (void)eAIntroViewDidFinish:(EAIntroViewController *)eAIntro {
    //发通知 欢迎界面展示完成
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WelcomeDidFinish" object:nil];
}
@end
