//
//  IdentityHttp.m
//  RealmDemo
//
//  Created by Mac on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "IdentityHttp.h"
#import "IdentityManager.h"

@implementation IdentityHttp
//获取accessToken
+ (NSURLSessionDataTask*)getAccessTokenhandler:(completionHandler)handler {
    NSString *urlPath = @"OAuth/access_token";
    id parameter = @{@"app_id":@"1a920974091344a38b16f8261550c084",@"app_secret":@"108ff221833bb6016fede79fee692873"};
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:parameter completionHandler:compleionHandler];
}
//系统账号密码登陆
+ (NSURLSessionDataTask*)loginWithEmail:(NSString*)email password:(NSString*)password handler:(completionHandler)handler {
    NSString *urlPath = @"Users/login";
    id parameter = @{@"email":email,@"password":password,@"access_token":[IdentityManager manager].identity.accessToken};
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:parameter completionHandler:compleionHandler];
}
#pragma mark -- 社会化登录
+ (NSURLSessionDataTask*)socialLogin:(NSString *)social_id media_type:(int)media_type token:(NSString *)token expires_in:(NSString *)expires_in client_type:(NSString *)client_type name:(NSString *)name avatar_url:(NSString *)avatar_url handler:(completionHandler)handler {
    NSString *urlPath = @"Users/social_login_new";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:social_id forKey:@"social_id"];
    [params setObject:@(media_type) forKey:@"media_type"];
    [params setObject:token forKey:@"token"];
    [params setObject:expires_in forKey:@"expires_in"];
    [params setObject:client_type forKey:@"client_type"];
    [params setObject:name forKey:@"name"];
    [params setObject:avatar_url forKey:@"avatar_url"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取在AppStore中的版本号
+ (NSURLSessionDataTask*)getSoftVersionHandler:(completionHandler)handler {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask * dataTask = [manager POST:@"http://itunes.apple.com/lookup?id=979426412" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = responseObject[@"results"];
        NSDictionary *dict = [array lastObject];
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(dict[@"version"],nil);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        MError *err = nil;
        if(error.code == -1009)//网络不可用
            err = [[MError alloc] initWithCode:-1009 statsMsg:@"网络不可用，请连接网络"];
        else//其他错误
            err = [[MError alloc] initWithCode:error.code statsMsg:error.domain];
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(nil,err);
        });
    }];
    return dataTask;
}
@end
