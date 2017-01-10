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
    E_HTTP_ERROR_QQ_UUID_ERROR                  = 10001,    //用accessToken获取qq的uuid，返回数据不正确 
};


@interface MError : NSObject

@property (nonatomic, assign) NSInteger statsCode;
@property (nonatomic, strong) NSString *statsMsg;

- (instancetype)initWithCode:(NSInteger)code statsMsg:(NSString*)statsMsg;
+ (MError *)error:(HTTP_ERROR_CODE)code;
- (NSString *)errorTips;

@end
