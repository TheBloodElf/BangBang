//
//  CMDeviceInfo.h
//  fadein
//
//  Created by Maverick on 15/12/3.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef MAIN_SCREEN_WIDTH
#define MAIN_SCREEN_WIDTH   [CMDeviceInfo mainScreenWidth]
#endif
#ifndef MAIN_SCREEN_HEIGHT
#define MAIN_SCREEN_HEIGHT  [CMDeviceInfo mainScreenHeight]
#endif

#ifndef MAIN_SCREEN_WIDTH_SCALE
#define MAIN_SCREEN_WIDTH_SCALE     [CMDeviceInfo mainScreenWidth] / 320.0f
#endif
#ifndef MAIN_SCREEN_HEIGHT_SCALE
#define MAIN_SCREEN_HEIGHT_SCALE    [CMDeviceInfo mainScreenHeight] / 568.0f
#endif


#ifndef IS_RETINA_35
#define IS_RETINA_35  ([CMDeviceInfo mainScreenHeight] == 480.0F)
#endif

#ifndef IS_RETINA_40
#define IS_RETINA_40  ([CMDeviceInfo mainScreenHeight] == 568.0f)
#endif

#ifndef IS_RETINA_47
#define IS_RETINA_47  ([CMDeviceInfo mainScreenHeight] == 667.0F)
#endif

#ifndef IS_RETINA_55
#define IS_RETINA_55  ([CMDeviceInfo mainScreenHeight] == 736.0F)
#endif




@interface CMDeviceInfo : NSObject

+ (NSString *)deviceType;

+ (CGFloat)mainScreenWidth;
+ (CGFloat)mainScreenHeight;

//设备唯一标识符
+ (NSString *)idfv;

//返回设备信息
+ (NSDictionary *)deviceInfo;

@end
