//
//  WBApiManager.m
//  BangBang
//
//  Created by Xiaoyafei on 15/11/5.
//  Copyright © 2015年 Kiwaro. All rights reserved.
//

#import "WBApiManager.h"

@implementation WBApiManager

#pragma mark - LifeCycle
+(instancetype)shareManager{
    static dispatch_once_t onceToken;
    static WBApiManager *instance;
    dispatch_once(&onceToken,^{
        instance = [[WBApiManager alloc]init];
    });
    return instance;
}

#pragma mark - WBApiDelegate
-(void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        if (_delegate && [_delegate respondsToSelector:@selector(managerDidRecvResponse:)]) {
            WBAuthorizeResponse *authorizeResponse = (WBAuthorizeResponse *)response;
            [_delegate managerDidRecvResponse:authorizeResponse];
        }
    }
}

-(void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}
@end
