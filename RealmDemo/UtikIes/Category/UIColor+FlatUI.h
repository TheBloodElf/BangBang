//
//  UIColor+FlatUI.h
//  FlatUI
//
//  Created by Jack Flintermann on 5/3/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (FlatUI)

//首页导航栏
+ (UIColor *) homeListColor;
//日程导航栏
+ (UIColor *) calendarColor;
//签到导航栏
+ (UIColor *) siginColor;
+ (UIColor *) colorFromHexCode:(NSString *)hexString;

+ (UIColor *) blendedColorWithForegroundColor:(UIColor *)foregroundColor
                              backgroundColor:(UIColor *)backgroundColor
                                 percentBlend:(CGFloat) percentBlend;

@end
