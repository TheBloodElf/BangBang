//
//  UIViewController+jumpRouter.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UIViewController+jumpRouter.h"
#import "ViewControllerGenerator.h"

@implementation UIViewController (jumpRouter)

#pragma mark -- 通用的，属性或者block都写到parameters中去
//非模态弹出控制器
- (void)presentControler:(NSString*)name parameters:(NSDictionary*)parameters{
    [self checkViewController:self];
    UIViewController *viewController = [ViewControllerGenerator getViewController:name];
    viewController.data = parameters;//因为data会比viewWillApper先执行，所以刚好可以达到给属性赋值的要求
    [self presentViewController:viewController animated:YES completion:nil];
}
//模态弹出控制器
- (void)modelPresentControler:(NSString*)name parameters:(NSDictionary*)parameters {
    UIViewController *viewController = [ViewControllerGenerator getViewController:name];
    viewController.providesPresentationContextTransitionStyle = YES;
    viewController.definesPresentationContext = YES;
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    viewController.data = parameters;//因为data会比viewWillApper先执行，所以刚好可以达到给属性赋值的要求
    [self presentViewController:viewController animated:NO completion:nil];
}
//导航推出控制器
- (void)pushControler:(NSString*)name parameters:(NSDictionary*)parameters {
    UINavigationController *navController = (id)self;
    [self checkNavigationController:navController];
    UIViewController *viewController = [ViewControllerGenerator getViewController:name ];
    viewController.data = parameters;//因为data会比viewWillApper先执行，所以刚好可以达到给属性赋值的要求
    [navController pushViewController:viewController animated:YES];
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
