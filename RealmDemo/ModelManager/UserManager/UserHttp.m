//
//  UserHttp.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UserHttp.h"
#import "UserManager.h"
@implementation UserHttp
//创建工作圈
+ (NSURLSessionDataTask*)createCompany:(NSString*)company_name company_type:(NSString*)company_type hasImage:(UIImage*)hasImage handler:(completionHandler)handler {
    NSString *urlPath = @"Users/register_phone";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:company_name forKey:@"company_name"];
    [params setObject:company_type forKey:@"company_type"];
    [params setObject:hasImage forKey:@"image"];
    [params setObject:[UserManager manager].user.user_guid forKey:@"user_guid"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
@end
