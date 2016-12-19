//
//  MError.h
//  fadein
//
//  Created by Maverick on 15/12/27.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, HTTP_ERROR_CODE) {
    E_HTTP_ERROR_NON_ERROR                      = 0,        //无错误
    
    E_HTTP_ERROR_UNKNOW_ERROR                   = -1000,    //未知错误
    E_HTTP_ERROR_DISCONNECTION                  = -1001,    //无链接
    E_HTTP_ERROR_REQUEST_SERIALIZER_FAIL        = -1002,    //请求创建失败
};


@interface MError : NSObject

@property (nonatomic, assign) NSInteger statsCode;
@property (nonatomic, strong) NSString *statsMsg;

- (instancetype)initWithCode:(NSInteger)code statsMsg:(NSString*)statsMsg;
+ (MError *)error:(HTTP_ERROR_CODE)code;
- (NSString *)errorTips;

@end
