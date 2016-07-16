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
#pragma mark -- 邀请链接
+ (NSURLSessionDataTask*)getInviteURL:(int)userNo companyNo:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"Common/get_invite_link_url_short";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
+ (NSURLSessionDataTask*)getReferrerURL:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"Common/get_referrer_url_short";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 修改用户信息
+ (NSURLSessionDataTask*)updateUserInfo:(User*)user handler:(completionHandler)handler {
    NSString *urlPath = @"Users/update_user";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:user.user_guid forKey:@"user_guid"];
    [params setObject:user.real_name forKey:@"real_name"];
    [params setObject:@(user.sex) forKey:@"sex"];
    [params setObject:user.mobile forKey:@"mobile"];
    [params setObject:user.QQ forKey:@"QQ"];
    [params setObject:user.weixin forKey:@"weixin"];
    [params setObject:user.mood forKey:@"mood"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 工作圈
//转让工作圈
+ (NSURLSessionDataTask*)transCompany:(int)companyNo ownerGuid:(NSString*)ownerGuid toGuid:(NSString*)toGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/transfer";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:ownerGuid forKey:@"owner_userguid"];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:toGuid forKey:@"to_userguid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//加入工作圈
+ (NSURLSessionDataTask*)joinCompany:(int)companyNo userGuid:(NSString*)userGuid joinReason:(NSString*)joinReason handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/join_company";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userGuid forKey:@"user_guid"];
    [params setObject:@(companyNo) forKey:@"company_no"];
     [params setObject:joinReason forKey:@"join_reason"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
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
//获取工作圈创建者信息
+ (NSURLSessionDataTask*)getCompanyOwner:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/company_admin_info";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//更新员工状态 如果在圈子中 那么退出圈子都是调的这个方法
+ (NSURLSessionDataTask*)updateEmployeeStatus:(NSString*)employeeGuid status:(int)status reason:(NSString*)reason handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/update_employee_state";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:employeeGuid forKey:@"employee_guid"];
    [params setObject:@(status) forKey:@"status"];
    [params setObject:reason forKey:@"reason"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//将员工加入群聊
+ (NSURLSessionDataTask*)joinRYGroup:(int)userNo companyNo:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/join";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//将员工移除群聊
+ (NSURLSessionDataTask*)quitRYGroup:(int)userNo companyNo:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/quit";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
@end
