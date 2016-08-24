//
//  UIViewController+jumpRouter.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UIViewController+jumpRouter.h"

@implementation UIViewController (jumpRouter)

- (instancetype)initWithParameters:(NSDictionary*)parameters {
    if(self = [self initWithNibName:nil bundle:nil]) {
        
    }
    return self;
}
#pragma mark -- 通用的，属性或者block都写到parameters中去
//非模态弹出控制器
- (void)presentControler:(NSString*)name parameters:(NSDictionary*)parameters {
    [self checkViewController:self];
    UIViewController *viewController = [self getViewController:name parameters:parameters];
    [self presentViewController:viewController animated:YES completion:nil];
}
//模态弹出控制器
- (void)modelPresentControler:(NSString*)name parameters:(NSDictionary*)parameters {
    UIViewController *viewController = [self getViewController:name parameters:parameters];
    viewController.providesPresentationContextTransitionStyle = YES;
    viewController.definesPresentationContext = YES;
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:viewController animated:NO completion:nil];
}
//导航推出控制器
- (void)pushControler:(NSString*)name parameters:(NSDictionary*)parameters {
    UINavigationController *navController = (id)self;
    [self checkNavigationController:navController];
    UIViewController *viewController = [self getViewController:name parameters:parameters];
    [navController pushViewController:viewController animated:YES];
}
//创建对象
- (UIViewController*)getViewController:(NSString*)name parameters:(NSDictionary*)parameters{
    UIViewController *viewController = [[NSClassFromString(name) alloc] initWithParameters:parameters];
    [self checkViewController:viewController];
    return viewController;
}
//检查对象
- (void)checkViewController:(id)viewController {
    if(![viewController isKindOfClass:[UIViewController class]]) {
        NSLog(@"这不是一个控制器");
        assert(NO);
    }
}
- (void)checkNavigationController:(id)viewController {
    if(![viewController isKindOfClass:[UINavigationController class]]) {
        NSLog(@"这不是一个导航视图控制器");
        assert(NO);
    }
}
@end
