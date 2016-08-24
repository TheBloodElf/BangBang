//
//  UIViewController+jumpRouter.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

//用于模块（一个模块可有多个控制器）之间的跳转
//模块内部不需要用，因为模块都是一起出现的
@interface UIViewController (jumpRouter)

#pragma mark -- 通用的跳转方法，属性或者block都写到parameters中去
//非模态弹出控制器
- (void)presentControler:(NSString*)name parameters:(NSDictionary*)parameters;
//模态弹出控制器
- (void)modelPresentControler:(NSString*)name parameters:(NSDictionary*)parameters;
//导航推出控制器
- (void)pushControler:(NSString*)name parameters:(NSDictionary*)parameters;

@end
