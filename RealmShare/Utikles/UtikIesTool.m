//
//  UtikIes.m
//  RealmDemo
//
//  Created by Mac on 16/7/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UtikIesTool.h"
//正式
//NSString* const KBSSDKAPIDomain = @"http://open.59bang.com/api/";
//测试
NSString* const KBSSDKAPIDomain = @"http://open.test.59bang.com/api/";

@implementation UtikIesTool

+ (CGFloat)mainScreenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)mainScreenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

@end
