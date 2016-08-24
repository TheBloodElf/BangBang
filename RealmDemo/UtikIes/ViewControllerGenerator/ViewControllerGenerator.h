//
//  ViewControllerGenerator.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>

//控制器创建工具
@interface ViewControllerGenerator : NSObject

//创建对象
+ (UIViewController*)getViewController:(NSString*)name;

@end
