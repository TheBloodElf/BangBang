//
//  UserHttp.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UserHttp.h"
#import "UserManager.h"
#import "IdentityManager.h"

@implementation UserHttp
#pragma mark -- 工作圈
+ (NSURLSessionDataTask*)createCompany:(NSString*)companyName userGuid:(NSString*)userGuid image:(UIImage*)image companyType:(int)companyType handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/create_company";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:companyName forKey:@"company_name"];
    [params setObject:userGuid forKey:@"user_guid"];
    //把图片压缩 然后弄成data
    [params setObject:image forKey:@"image"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    [params setObject:@(companyType) forKey:@"company_type"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取圈子员工列表
+ (NSURLSessionDataTask*)getEmployeeCompnyNo:(int)companyNo status:(int)status userGuid:(NSString*)userGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/employee_list_new";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(status) forKey:@"status"];
    [params setObject:@(100000) forKey:@"page_size"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    [params setObject:userGuid forKey:@"user_guid"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取用户所在工作圈
+ (NSURLSessionDataTask*)getCompanysUserGuid:(NSString*)userGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/user_companies";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userGuid forKey:@"user_guid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//修改工作圈信息
+ (NSURLSessionDataTask*)updateCompany:(int)companyNo companyName:(NSString*)companyName companyType:(int)companyType logo:(NSString*)logo handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/update_company";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(companyType) forKey:@"company_type"];
    [params setObject:companyName forKey:@"company_name"];
    [params setObject:logo forKey:@"logo"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取工作圈列表
+ (NSURLSessionDataTask*)getCompanyList:(NSString*)companyName pageSize:(int)pageSize pageIndex:(int)pageIndex handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:companyName forKey:@"company_name"];
    [params setObject:@(pageIndex) forKey:@"page_index"];
    [params setObject:@(pageSize) forKey:@"page_size"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
@end
