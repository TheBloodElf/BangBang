//
//  NSObject+Tips.h
//  Foomoo
//
//  Created by QFish on 6/6/14.
//  Copyright (c) 2014 QFish.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

#pragma mark - UIView
/**
 *  直接在视图上显示提示信息
 */
@interface UIView (Tips)

- (MBProgressHUD *)showMessageTips:(NSString *)message;
- (MBProgressHUD *)showSuccessTips:(NSString *)message;
- (MBProgressHUD *)showFailureTips:(NSString *)message;
- (MBProgressHUD *)showLoadingTips:(NSString *)message;
- (MBProgressHUD *)showFailureTipsWithYOffset:(NSString *)message;
- (MBProgressHUD *)showUpImageSuccessTips:(NSString *)message;

- (void)dismissTips;

@end

#pragma mark - UIViewController

@interface UIViewController (Tips)

- (MBProgressHUD *)showMessageTips:(NSString *)message;
- (MBProgressHUD *)showSuccessTips:(NSString *)message;
- (MBProgressHUD *)showFailureTips:(NSString *)message;
- (MBProgressHUD *)showLoadingTips:(NSString *)message;
- (MBProgressHUD *)showFailureTipsWithYOffset:(NSString *)message;
- (MBProgressHUD *)showUpImageSuccessTips:(NSString *)message;
- (void)dismissTips;

@end