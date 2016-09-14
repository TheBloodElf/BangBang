//
//  RYChatManager.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/18.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//网络状态发生变化
@protocol NetWorkStatusChangeDelegate <NSObject>

- (void)netWorkStatusChange:(RCConnectionStatus)status;

@end

//融云管理器
@interface RYChatManager : NSObject<RCIMUserInfoDataSource,RCIMGroupInfoDataSource,RCIMConnectionStatusDelegate>

@property (nonatomic, weak) id<NetWorkStatusChangeDelegate> netWorkDelegate;

+ (RYChatManager *) shareInstance;
//同步群组
- (void)syncRYGroup;
//注册
- (void)registerRYChat;

@end
