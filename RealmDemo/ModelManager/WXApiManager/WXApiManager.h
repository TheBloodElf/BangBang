//
//  WXApiManager.h
//  BangBang
//
//  Created by Xiaoyafei on 15/11/5.
//  Copyright © 2015年 Kiwaro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
//微信登录管理器
@protocol WXApiManagerDeleagate <NSObject>

@optional

-(void)managerDidRecvAuthResponse:(SendAuthResp *)response;

@end

@interface WXApiManager : NSObject<WXApiDelegate>

@property (nonatomic,assign) id<WXApiManagerDeleagate> delegate;

+(instancetype)sharedManager;

@end
