//
//  UIView+parentViewController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/23.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//找到自己所在的视图控制器
@interface UIView (parentViewController)

- (UIViewController*)parentViewController;

@end
