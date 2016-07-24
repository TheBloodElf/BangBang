//
//  GeTuiSdkManager.h
//  RealmDemo
//
//  Created by Mac on 16/7/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//个推管理器
@interface GeTuiSdkManager : NSObject

+ (instancetype)manager;

- (void)startGeTuiSdk;//初始化个推
- (void)stopGeTuiSdk;//停止个推
- (void)registerDeviceToken:(NSString*)deviceToken;//设置设备token

@end
