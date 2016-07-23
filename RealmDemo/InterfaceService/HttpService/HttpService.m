//
//  HttpService.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HttpService.h"
#import "IdentityManager.h"

@implementation HttpService
{
    //检查网络是否连接
    AFNetworkReachabilityManager *_reachabilityManager;
    //一般的网络请求服务
    AFHTTPSessionManager *_dataSessionManager;
}

#pragma mark -
#pragma mark - SINGLETON

static HttpService * __singleton__;

+ (HttpService *)service {
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{ __singleton__ = [[[self class] alloc] init]; } );
    return __singleton__;
}


#pragma mark -
#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        _reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        [_reachabilityManager startMonitoring];
        [self initManagers];
    }
    return self;
}

//普通请求
- (NSURLSessionDataTask *)sendRequestWithHttpMethod:(HTTP_REQUEST_METHOD)method
                                            URLPath:(NSString *)pathStr
                                         parameters:(id)parameters
                                  completionHandler:(completionHandler)completionHandler
{
    //开始菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //初始化请求
    NSString *urlStr = [[NSURL URLWithString:pathStr relativeToURL:_dataSessionManager.baseURL] absoluteString];
    NSString *methodStr = [self stringWithMethod:method];
    NSMutableURLRequest *request = [_dataSessionManager.requestSerializer requestWithMethod:methodStr URLString:urlStr parameters:parameters error:nil];
    __block NSURLSessionDataTask *task = nil;
    task = [_dataSessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //结束菊花
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //取消请求 放弃处理
        if (error.code == NSURLErrorCancelled) {
            return;
        }
        //判断结果
        MError *err = nil;
        id data = nil;
        NSDictionary *responseObjectDic = [responseObject mj_keyValues];
        //有的返回结果不包含code，这种就是成功的意思，奇葩啊。。。
        if([[responseObjectDic allKeys] containsObject:@"code"]) {
            NSInteger resultCode = [responseObjectDic[@"code"] integerValue];
            if(resultCode == 0) {//0表示成功
                data = responseObjectDic[@"data"];
            } else {
                err = [[MError alloc] initWithCode:resultCode statsMsg:responseObjectDic[@"message"]];
            }
        } else {
            data = responseObject;
        }
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(data, err);
        });
    }];
    
    //发起请求任务
    [task resume];
    return task;
}

- (NSString *)stringWithMethod:(HTTP_REQUEST_METHOD)method {
    switch (method) {
        case E_HTTP_REQUEST_METHOD_GET:     return @"GET";      break;
        case E_HTTP_REQUEST_METHOD_HEAD:    return @"HEAD";     break;
        case E_HTTP_REQUEST_METHOD_POST:    return @"POST";     break;
        case E_HTTP_REQUEST_METHOD_PUT:     return @"PUT";      break;
        case E_HTTP_REQUEST_METHOD_PATCH:   return @"PATCH";    break;
        case E_HTTP_REQUEST_METHOD_DELETE:  return @"DELETE";   break;
        default:
            break;
    }
    return @"";
}
- (void)cleanAllTask {
    [self invalidateManagers];
    [self initManagers];
}
- (void)invalidateManagers {
    [_dataSessionManager invalidateSessionCancelingTasks:YES];
}

#pragma mark -
#pragma mark - Ptavite Methods

- (void)initManagers {
    _dataSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    [_dataSessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [_dataSessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    
}

@end
