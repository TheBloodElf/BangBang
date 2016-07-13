//
//  HttpService.h
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterfaceConfig.h"
#import "MError.h"

typedef NS_ENUM(NSUInteger, HTTP_REQUEST_METHOD) {
    E_HTTP_REQUEST_METHOD_GET   = 0,
    E_HTTP_REQUEST_METHOD_HEAD,
    E_HTTP_REQUEST_METHOD_POST,
    E_HTTP_REQUEST_METHOD_PUT,
    E_HTTP_REQUEST_METHOD_PATCH,
    E_HTTP_REQUEST_METHOD_DELETE,
};

typedef void(^completionHandler)(id data,MError *error);

@interface HttpService : NSObject

+ (HttpService *)service;
//发送普通数据请求
- (NSURLSessionDataTask *)sendRequestWithHttpMethod:(HTTP_REQUEST_METHOD)method
                                            URLPath:(NSString *)pathStr
                                         parameters:(id)parameters
                                  completionHandler:(completionHandler)completionHandler;
@end
