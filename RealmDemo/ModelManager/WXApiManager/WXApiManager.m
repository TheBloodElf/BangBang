//
//  WXApiManager.m
//  BangBang
//
//  Created by Xiaoyafei on 15/11/5.
//  Copyright © 2015年 Kiwaro. All rights reserved.
//

#import "WXApiManager.h"

@implementation WXApiManager

#pragma mark - lifeCycle

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken,^{
        instance = [[WXApiManager alloc]init];
    });
    return instance;
}

#pragma mark - WXApiDelegate
-(void)onReq:(BaseReq *)req{

}

-(void)onResp:(BaseResp *)resp{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (_delegate && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [_delegate managerDidRecvAuthResponse:authResp];
        }
    }
}
@end
