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
#import "RequestManagerController.h"
#import "BushManageViewController.h"
#import "MainBusinessController.h"

@interface BusinessController () {
    UINavigationController *_businessNav;//这个导航用于弹出通知信息，是业务模块的根控制器
}
@end

@implementation BusinessController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //创建界面
    REFrostedViewController *_rEFrostedView = [[REFrostedViewController alloc] initWithContentViewController:[MainBusinessController new] menuViewController:[LeftMenuController new]];
    _rEFrostedView.direction = REFrostedViewControllerDirectionLeft;
    _rEFrostedView.menuViewSize = CGSizeMake(MAIN_SCREEN_WIDTH*3/4, MAIN_SCREEN_HEIGHT + 44);
    _rEFrostedView.liveBlur = YES;
    //创建业务根视图控制器
    _businessNav = [[UINavigationController alloc] initWithRootViewController:_rEFrostedView];
    [self addChildViewController:_businessNav];
    [_businessNav.view willMoveToSuperview:self.view];
    [_businessNav willMoveToParentViewController:self];
    [_businessNav setNavigationBarHidden:YES animated:YES];
    _businessNav.navigationBar.translucent = NO;
    _businessNav.navigationBar.barTintColor = [UIColor homeListColor];
    [self.view addSubview:_businessNav.view];
    
    //添加spotlight索引
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {}];
    [self insertSearchableItem:UIImagePNGRepresentation([UIImage imageNamed:@"default_image_icon"]) spotlightTitle:@"帮帮管理助手" description:@"身边不可获取的办公软件" keywords:@[@"日程",@"任务",@"会议",@"签到"] spotlightInfo:@"OpenSoft" domainId:@"com.lottak.BangBang"];
#endif
}
- (void)insertSearchableItem:(NSData *)photo spotlightTitle:(NSString *)spotlightTitle description:(NSString *)spotlightDesc keywords:(NSArray *)keywords spotlightInfo:(NSString *)spotlightInfo domainId:(NSString *)domainId {
    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeImage];
    attributeSet.title = spotlightTitle;                // 标题
    attributeSet.keywords = keywords;                   // 关键字,NSArray格式
    attributeSet.contentDescription = spotlightDesc;    // 描述
    attributeSet.thumbnailData = photo;                 // 图标, NSData格式
    // spotlightInfo 可以作为一些数据传递给接受的地方
    // domainId      id,通过这个id来判断是哪个spotlight
    CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:spotlightInfo domainIdentifier:domainId attributeSet:attributeSet];
    [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler:^(NSError * error) {}];
}
@end
