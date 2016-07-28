//
//  WBApiManager.h
//  BangBang
//
//  Created by Xiaoyafei on 15/11/5.
//  Copyright © 2015年 Kiwaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboSDK.h"
//微博登录管理器
@protocol WBApiManagerDelegate <NSObject>

@optional
-(void)managerDidRecvResponse:(WBAuthorizeResponse*)response;

@end

@interface WBApiManager : NSObject<WeiboSDKDelegate>

@property(nonatomic,assign) id<WBApiManagerDelegate> delegate;

+(instancetype)shareManager;

@end
