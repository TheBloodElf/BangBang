//
//  RYChatManager.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/18.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RYChatManager : NSObject<RCIMUserInfoDataSource,RCIMGroupInfoDataSource,RCIMConnectionStatusDelegate>

+ (RYChatManager *) shareInstance;
//同步群组
- (void)syncRYGroup;
//注册
- (void)registerRYChat;

@end
