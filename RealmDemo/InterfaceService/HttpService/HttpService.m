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
        //判断结果
        MError *err = nil;
        id data = nil;
        //如果是请求时的错误
        if(error) {
            if(error.code == -1009)//网络不可用
                err = [[MError alloc] initWithCode:-1009 statsMsg:@"网络不可用，请连接网络"];
            else//其他错误
                err = [[MError alloc] initWithCode:error.code statsMsg:error.domain];
        } else {//请求没有错
            NSDictionary *responseObjectDic = [responseObject mj_keyValues];
            //有的返回结果不包含code，这种就是成功的意思，奇葩啊。。。
            if([[responseObjectDic allKeys] containsObject:@"code"]) {
                NSInteger resultCode = [responseObjectDic[@"code"] integerValue];
                if(resultCode == 0) {//0表示成功
                    data = responseObjectDic[@"data"];
                } else {//服务器返回的错误
                    err = [[MError alloc] initWithCode:resultCode statsMsg:responseObjectDic[@"message"]];
                }
            } else {
                data = responseObject;
            }
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
//下载文件
- (NSURLSessionDownloadTask *)downRequesURLPath:(NSString *)pathStr  locFilePath:(NSString*)locFilePath completionHandler:(completionHandler)completionHandler{
    //开始菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:pathStr]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLSessionDownloadTask * dataTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:[locFilePath stringByAppendingPathComponent:response.suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //判断结果
        MError *err = nil;
        id data;
        if(error) {
            err = [[MError alloc] initWithCode:error.code statsMsg:error.domain];
        } else {
            data = [response mj_keyValues];
        }
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(data, err);
        });
        
    }];
    
    //发起请求任务
    [dataTask resume];
    return dataTask;
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
