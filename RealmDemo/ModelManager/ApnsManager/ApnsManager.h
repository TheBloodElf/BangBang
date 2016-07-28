//
//  ApnsManager.h
//  RealmDemo
//
//  Created by Mac on 16/7/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//本地推动管理器
@interface ApnsManager : NSObject

+ (instancetype)manager;
//注册通知
- (void)registerNotification;
//收到本地推送
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification;

@end
