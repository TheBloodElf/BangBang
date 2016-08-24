//
//  ViewControllerGenerator.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ViewControllerGenerator.h"

@implementation ViewControllerGenerator
//创建对象
+ (UIViewController*)getViewController:(NSString*)name parameters:(NSDictionary*)parameters{
    UIViewController *viewController = [[NSClassFromString(name) alloc] initWithParameters:parameters];
    [self checkViewController:viewController];
    return viewController;
}
//检查对象
+ (void)checkViewController:(id)viewController {
    if(![viewController isKindOfClass:[UIViewController class]]) {
        NSLog(@"这不是一个控制器");
        assert(NO);
    }
}
@end
