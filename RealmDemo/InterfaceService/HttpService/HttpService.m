//
//  HttpService.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HttpService.h"
#import "IdentityManager.h"
//所以我们在测试环境是要把info.plist 中Allow Arbitrary Loads设置成yes
//        正式环境是要把info.plist 中Allow Arbitrary Loads设置成no
//测试环境不需要对afn做任何配置
//正式环境需要对afn加ssl验证
@implementation HttpService
{
    //一般的网络请求服务
    AFHTTPSessionManager *_dataSessionManager;
    //上传文件
    AFHTTPSessionManager *_uploadSessionManager;
    //下载文件
    AFHTTPSessionManager *_downSessionManager;
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
    NSURLSessionDownloadTask * dataTask = [_downSessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:[locFilePath stringByAppendingPathComponent:response.suggestedFilename]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //结束菊花
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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

//上传文件
- (NSURLSessionDataTask *)uploadRequestURLPath:(NSString *)pathStr parameters:(id)parameters image:(UIImage*)image name:(NSString*)name completionHandler:(completionHandler)completionHandler {
    //结束菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask * dataTask = [_uploadSessionManager POST:pathStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:[image dataInNoSacleLimitBytes:MaXPicSize] name:name fileName:[NSString stringWithFormat:@"%@.jpg",@([NSDate date].timeIntervalSince1970 * 1000)] mimeType:@"image/jpeg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //结束菊花
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if([responseObject[@"code"] integerValue] == 0) {
            completionHandler(responseObject,nil);
        } else {
            completionHandler(nil,[[MError alloc] initWithCode:[responseObject[@"code"] intValue] statsMsg:responseObject[@"message"]]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completionHandler(nil,[[MError alloc] initWithCode:error.code statsMsg:error.domain]);
    }];
    
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
    [_uploadSessionManager invalidateSessionCancelingTasks:YES];
    [_downSessionManager invalidateSessionCancelingTasks:YES];
}

#pragma mark -
#pragma mark - Ptavite Methods  

- (void)initManagers {
    //普通数据请求
    _dataSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    [_dataSessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [_dataSessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
//    [_dataSessionManager setSecurityPolicy:[self customSecurityPolicy]];
    //上传文件
    _uploadSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    [_uploadSessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [_uploadSessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
//    [_uploadSessionManager setSecurityPolicy:[self customSecurityPolicy]];
    //下载文件
    _downSessionManager = [AFHTTPSessionManager manager];
    [_downSessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [_downSessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
//    [_downSessionManager setSecurityPolicy:[self customSecurityPolicy]];
}
- (AFSecurityPolicy *)customSecurityPolicy
{
    //先导入证书，找到证书的路径
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"bangbangssl" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    //AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    NSSet *set = [[NSSet alloc] initWithObjects:certData, nil];
    securityPolicy.pinnedCertificates = set;
    return securityPolicy;
}

@end
