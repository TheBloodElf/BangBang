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
+ (UIViewController*)getViewController:(NSString*)name{
    UIViewController *viewController = nil;
    //先从story中加载 看有没有
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
    NSDictionary *allNibName = [story mj_keyValues][@"identifierToNibNameMap"];
    if([allNibName.allValues containsObject:name]) {
        viewController = [story instantiateViewControllerWithIdentifier:name];
        return viewController;
    }
    //直接初始化
    viewController = [NSClassFromString(name) new];
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
