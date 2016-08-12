//
//  UtikIes.h
//  RealmDemo
//
//  Created by Mac on 16/7/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSObject+Tips.h"

#ifndef MAIN_SCREEN_WIDTH
#define MAIN_SCREEN_WIDTH   [UtikIesTool mainScreenWidth]
#endif
#ifndef MAIN_SCREEN_HEIGHT
#define MAIN_SCREEN_HEIGHT  [UtikIesTool mainScreenHeight]
#endif

extern NSString *const KBSSDKAPIDomain;

@interface UtikIesTool : NSObject

+ (CGFloat)mainScreenWidth;
+ (CGFloat)mainScreenHeight;

@end
