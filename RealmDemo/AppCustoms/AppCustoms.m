
//
//  AppCustoms.m
//  fadein
//
//  Created by Maverick on 16/1/26.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "AppCustoms.h"

@implementation AppCustoms

#pragma mark -
#pragma mark - SINGLETON

static AppCustoms * __singleton__;

+ (AppCustoms *)customs {
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{ __singleton__ = [[[self class] alloc] init]; } );
    return __singleton__;
}

#pragma mark -
#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:[UIColor homeListColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:
         @{NSFontAttributeName:[UIFont systemFontOfSize:17],
           NSForegroundColorAttributeName:[UIColor whiteColor]}];
        [[UISearchBar appearance] setTintColor:[UIColor colorWithRed:247/255.f green:247/255.f blue:247/255.f alpha:1]];
        [[UISearchBar appearance] setBarTintColor:[UIColor colorWithRed:247/255.f green:247/255.f blue:247/255.f alpha:1]];
        [[UISearchBar appearance] layer].borderColor = [UIColor whiteColor].CGColor;
        [[UISearchBar appearance] layer].borderWidth = 1;
        //让UIAlertView等视图显示的文字颜色变成自己的颜色
//        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0f) {
//            [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertView class]]] setTintColor:[UIColor blackColor]];
//            [[UIView appearanceWhenContainedInInstancesOfClasses:@[[UIAlertController class]]] setTintColor:[UIColor blackColor]];
//        } else {
//            [[UIView appearanceWhenContainedIn:[UIAlertView class], nil] setTintColor:[UIColor blackColor]];
//            [[UIView appearanceWhenContainedIn:[UIAlertController class], nil] setTintColor:[UIColor blackColor]];
//        }
    }
    return self;
}

@end
