//
//  UIView+parentViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/23.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UIView+parentViewController.h"

@implementation UIView (parentViewController)

- (UIViewController*)parentViewController {
    id target = self;
    while (target) {
        target = ((UIResponder*)target).nextResponder;
        if([target isKindOfClass:[UIViewController class]]) break;
    }
    return target;
}

@end
