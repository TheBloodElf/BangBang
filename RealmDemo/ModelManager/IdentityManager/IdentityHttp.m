//
//  IdentityHttp.m
//  RealmDemo
//
//  Created by Mac on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "IdentityHttp.h"

@implementation IdentityHttp
//获取accessToken
- (NSURLSessionDataTask*)getAccessTokenhandler:(completionHandler)handler {
    NSString *urlPath = @"OAuth/access_token";
    id parameter = @{@"app_id":@"1a920974091344a38b16f8261550c084",@"app_secret":@"108ff221833bb6016fede79fee692873"};
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:parameter completionHandler:compleionHandler];
}
//系统账号密码登陆
- (NSURLSessionDataTask*)loginWithEmail:(NSString*)email password:(NSString*)password handler:(completionHandler)handler {
    NSString *urlPath = @"Users/register_phone";
    id parameter = @{@"email":email,@"password":password};
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:parameter completionHandler:compleionHandler];
}
//第三方登陆
- (NSURLSessionDataTask*)regWithphone:(NSString *)phone password:(NSString *)password confirm_password:(NSString *)confirm_password real_name:(NSString *)real_name captcha:(NSString *)captcha handler:(completionHandler)handler {
    NSString *urlPath = @"Users/login";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:phone forKey:@"phone"];
    [params setObject:password forKey:@"password"];
    [params setObject:confirm_password forKey:@"confirm_password"];
    if (captcha) {
        [params setObject:captcha forKey:@"captcha"];
    }
    [params setObject:@"iOS" forKey:@"client_type"];
    real_name = [real_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [params setObject:real_name forKey:@"real_name"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
@end
