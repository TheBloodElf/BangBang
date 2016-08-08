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
#pragma mark -- 上传图片
//上传图片 得到地址
+ (NSURLSessionDataTask*)updateImageGuid:(NSString*)guid image:(UIImage*)image handler:(completionHandler)handler {
    //开始菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    UserManager *userManager = [UserManager manager];
    NSDictionary *parameters = @{@"user_guid":userManager.user.user_guid,@"app_guid":guid,@"access_token":[IdentityManager manager].identity.accessToken,@"company_no":@(userManager.user.currCompany.company_no)};
    NSURLSessionDataTask * dataTask = [manager POST:@"Attachments/upload_attachment" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        NSData *currData = [image dataInNoSacleLimitBytes:MaXPicSize];
        [formData appendPartWithFileData:currData name:@"doc" fileName:[NSString stringWithFormat:@"%@.jpg",@([[NSDate date] timeIntervalSince1970])] mimeType:@"image/jpeg"];
    }progress:nil success:^(NSURLSessionDataTask * task, id  responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //判断结果
        MError *err = nil;
        id data = nil;
        NSDictionary *responseObjectDic = [responseObject mj_keyValues];
        if([responseObjectDic[@"code"] integerValue] == 0) {
            data = responseObjectDic[@"data"];
        } else {
            err = [MError new];
        }
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data,err);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //开始菊花
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        handler(nil,[MError new]);
    }];
    
    [dataTask resume];
    return dataTask;
}
#pragma mark -- 社会化登录
+ (NSURLSessionDataTask*)socialLogin:(NSString *)social_id
                          media_type:(NSString *)media_type
                               token:(NSString *)token
                          expires_in:(NSString *)expires_in
                         client_type:(NSString *)client_type
                                name:(NSString *)name
                          avatar_url:(NSString *)avatar_url handler:(completionHandler)handler {
    NSString *urlPath = @"Users/social_login_new";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:social_id forKey:@"social_id"];
    [params setObject:media_type forKey:@"media_type"];
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
#pragma mark -- 个推
//绑定个推别名
+ (NSURLSessionDataTask*)setupAPNSDevice:(NSString*)clientId userNo:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"PushMessage/bind_alias";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:clientId forKey:@"client_id"];
    [params setObject:@"2" forKey:@"client_type"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 融云
//同步群组
+ (NSURLSessionDataTask*)syncRYGroup:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/sync";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取融云token
+ (NSURLSessionDataTask*)getRYToken:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/token";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
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
    NSMutableDictionary *params = [user.JSONDictionary mutableCopy];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//修改用户头像
+ (NSURLSessionDataTask*)updateUserAvater:(UIImage*)image userGuid:(NSString*)userGuid handler:(completionHandler)handler {
    //开始菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    NSDictionary *parameters = @{@"user_guid":userGuid,@"access_token":[IdentityManager manager].identity.accessToken};
    NSURLSessionDataTask * dataTask = [manager POST:@"Users/update_avatar" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        NSData *currData = [image dataInNoSacleLimitBytes:MaXPicSize];
        [formData appendPartWithFileData:currData name:@"doc" fileName:[NSString stringWithFormat:@"%@.jpg",@([[NSDate date] timeIntervalSince1970])] mimeType:@"image/jpeg"];
    }progress:nil success:^(NSURLSessionDataTask * task, id  responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //判断结果
        MError *err = nil;
        id data = nil;
        NSDictionary *responseObjectDic = [responseObject mj_keyValues];
        if([responseObjectDic[@"code"] integerValue] == 0) {
            data = responseObjectDic[@"data"];
        } else {
            err = [MError new];
        }
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data,err);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        handler(nil,[MError new]);
    }];
    
    [dataTask resume];
    return dataTask;
}
#pragma mark -- 工作圈
//获取工作圈信息
+ (NSURLSessionDataTask*)getCompanyInfo:(int)companyId handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/company_info";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyId) forKey:@"company_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
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
//创建工作圈
+ (NSURLSessionDataTask*)createCompany:(NSString*)companyName userGuid:(NSString*)userGuid image:(UIImage*)image companyType:(int)companyType handler:(completionHandler)handler {
    //开始菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:companyName forKey:@"company_name"];
    [params setObject:userGuid forKey:@"user_guid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    [params setObject:@(companyType) forKey:@"company_type"];
    NSURLSessionDataTask * dataTask = [manager POST:@"Companies/create_company" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        NSData *currData = [image dataInNoSacleLimitBytes:MaXPicSize];
        [formData appendPartWithFileData:currData name:@"image" fileName:[NSString stringWithFormat:@"%@.jpg",@([[NSDate date] timeIntervalSince1970])] mimeType:@"image/jpeg"];
    }progress:nil success:^(NSURLSessionDataTask * task, id  responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //判断结果
        MError *err = nil;
        id data = nil;
        NSDictionary *responseObjectDic = [responseObject mj_keyValues];
        if([responseObjectDic[@"code"] integerValue] == 0) {
            data = responseObjectDic[@"data"];
        } else {
            err = [[MError alloc] initWithCode:[responseObjectDic[@"code"] intValue] statsMsg:responseObjectDic[@"message"]];
        }
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data,err);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        handler(nil,[[MError alloc] initWithCode:error.code statsMsg:error.domain]);
    }];
    
    [dataTask resume];
    return dataTask;
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
//获取用户所在工作圈 所有状态
+ (NSURLSessionDataTask*)getCompanysUserGuid:(NSString*)userGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Companies/user_all_companies";
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
//修改工作圈logo
+ (NSURLSessionDataTask*)updateConpanyAvater:(UIImage*)image companyNo:(int)companyNo userGuid:(NSString*)userGuid handler:(completionHandler)handler {
    //开始菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    NSDictionary *parameters = @{@"user_guid":userGuid,@"access_token":[IdentityManager manager].identity.accessToken,@"company_no":@(companyNo)};
    NSURLSessionDataTask * dataTask = [manager POST:@"Companies/company_logo" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        NSData *currData = [image dataInNoSacleLimitBytes:MaXPicSize];
        [formData appendPartWithFileData:currData name:@"doc" fileName:[NSString stringWithFormat:@"%@.jpg",@([[NSDate date] timeIntervalSince1970])] mimeType:@"image/jpeg"];
    }progress:nil success:^(NSURLSessionDataTask * task, id  responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //判断结果
        MError *err = nil;
        id data = nil;
        NSDictionary *responseObjectDic = [responseObject mj_keyValues];
        if([responseObjectDic[@"code"] integerValue] == 0) {
            data = responseObjectDic[@"data"];
        } else {
            err = [MError new];
        }
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data,err);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //开始菊花
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        handler(nil,[MError new]);
    }];
    
    [dataTask resume];
    return dataTask;
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
#pragma mark -- 讨论组
//获取用户通讯录中的讨论组
+ (NSURLSessionDataTask*)getUserDiscuss:(int)userNo handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/get_discuss_list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//添加讨论组
+ (NSURLSessionDataTask*)addUserDiscuss:(int)userNo discussId:(NSString*)discussId discussTitle:(NSString*)discussTitle handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/save_discuss_info";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:discussId forKey:@"discuss_id"];
    [params setObject:discussTitle forKey:@"discuss_title"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//删除讨论组
+ (NSURLSessionDataTask*)delUserDiscuss:(int)userNo discussId:(NSString*)discussId handler:(completionHandler)handler {
    NSString *urlPath = @"RongClouds/delete_discuss";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(userNo) forKey:@"user_no"];
    [params setObject:discussId forKey:@"discuss_id"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 日程
//创建日程
+ (NSURLSessionDataTask*)createUserCalendar:(Calendar*)calendar handler:(completionHandler)handler {
    NSString *urlPath = @"Calendars/add_v3";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(calendar.company_no) forKey:@"company_no"];
    [params setObject:calendar.event_name forKey:@"event_name"];
    [params setObject:calendar.descriptionStr forKey:@"description"];
    [params setObject:calendar.address forKey:@"address"];
    [params setObject:@(calendar.begindate_utc) forKey:@"begindate_utc"];
    [params setObject:@(calendar.enddate_utc) forKey:@"enddate_utc"];
    [params setObject:@(calendar.is_allday) forKey:@"is_allday"];
    [params setObject:calendar.app_guid forKey:@"app_guid"];
    [params setObject:calendar.target_id forKey:@"target_id"];
    [params setObject:@(calendar.repeat_type) forKey:@"repeat_type"];
    [params setObject:@(calendar.is_alert) forKey:@"is_alert"];
    [params setObject:@(calendar.alert_minutes_before) forKey:@"alert_minutes_before"];
    [params setObject:@(calendar.alert_minutes_after) forKey:@"alert_minutes_after"];
    [params setObject:calendar.user_guid forKey:@"user_guid"];
    [params setObject:calendar.created_by forKey:@"created_by"];
    [params setObject:@(calendar.emergency_status) forKey:@"emergency_status"];
    [params setObject:calendar.rrule forKey:@"rrule"];
    [params setObject:@(calendar.r_begin_date_utc) forKey:@"r_begin_date_utc"];
    [params setObject:@(calendar.r_end_date_utc) forKey:@"r_end_date_utc"];
    [params setObject:calendar.members forKey:@"members"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//修改日程
+ (NSURLSessionDataTask*)updateUserCalendar:(Calendar*)calendar handler:(completionHandler)handler {
    NSString *urlPath = @"Calendars/update_v3";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(calendar.id) forKey:@"id"];
    [params setObject:@(calendar.company_no) forKey:@"company_no"];
    [params setObject:calendar.event_name forKey:@"event_name"];
    [params setObject:calendar.descriptionStr forKey:@"description"];
    [params setObject:calendar.address forKey:@"address"];
    [params setObject:@(calendar.begindate_utc) forKey:@"begindate_utc"];
    [params setObject:@(calendar.enddate_utc) forKey:@"enddate_utc"];
    [params setObject:@(calendar.is_allday) forKey:@"is_allday"];
    [params setObject:calendar.app_guid forKey:@"app_guid"];
    [params setObject:calendar.target_id forKey:@"article_id"];
    [params setObject:@(calendar.repeat_type) forKey:@"repeat_type"];
    [params setObject:@(calendar.is_alert) forKey:@"is_alert"];
    [params setObject:@(calendar.alert_minutes_before) forKey:@"alert_minutes_before"];
    [params setObject:@(calendar.alert_minutes_after) forKey:@"alert_minutes_after"];
    [params setObject:calendar.user_guid forKey:@"user_guid"];
    [params setObject:calendar.created_by forKey:@"created_by"];
    [params setObject:@(calendar.emergency_status) forKey:@"emergency_status"];
    [params setObject:calendar.rrule forKey:@"rrule"];
    [params setObject:@(calendar.r_begin_date_utc) forKey:@"r_begin_date_utc"];
    [params setObject:@(calendar.r_end_date_utc) forKey:@"r_end_date_utc"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取用户所有日程
+ (NSURLSessionDataTask*)getUserCalendar:(NSString*)userGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Calendars/list_v3";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"1" forKey:@"begin_date"];
    [params setObject:@"1756809030000" forKey:@"end_date"];
    [params setObject:@(1) forKey:@"page_index"];
    [params setObject:@(100000000000) forKey:@"page_size"];
    [params setObject:@"desc" forKey:@"order_by"];
    [params setObject:userGuid forKey:@"user_guid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 签到
//上传签到附件
+ (NSURLSessionDataTask*)uploadSiginPic:(UIImage*)image siginId:(int)siginId userGuid:(NSString*)userGuid companyNo:(int)companyNo handler:(completionHandler)handler {
    //开始菊花
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    NSDictionary *parameters = @{@"user_guid":userGuid,@"access_token":[IdentityManager manager].identity.accessToken,@"attendance_id":@(siginId),@"company_no":@(companyNo)};
    NSURLSessionDataTask * dataTask = [manager POST:@"Attachments/upload_attachment" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        NSData *currData = [image dataInNoSacleLimitBytes:MaXPicSize];
        [formData appendPartWithFileData:currData name:@"doc" fileName:[NSString stringWithFormat:@"%@.jpg",@([[NSDate date] timeIntervalSince1970])] mimeType:@"image/jpeg"];
    }progress:nil success:^(NSURLSessionDataTask * task, id  responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //判断结果
        MError *err = nil;
        id data = nil;
        NSDictionary *responseObjectDic = [responseObject mj_keyValues];
        if([responseObjectDic[@"code"] integerValue] == 0) {
            data = responseObjectDic[@"data"];
        } else {
            err = [MError new];
        }
        //主线程执行回调
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(data,err);
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //开始菊花
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        handler(nil,[MError new]);
    }];
    
    [dataTask resume];
    return dataTask;
}
//提交签到信息
+ (NSURLSessionDataTask*)sigin:(SignIn*)sigin handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/sign_v3_2";
    NSMutableDictionary *params = [[sigin JSONDictionary] mutableCopy];
    [params setObject:sigin.descriptionStr forKey:@"description"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取今天的签到记录
+ (NSURLSessionDataTask*)getSiginList:(int)companyNo employeeGuid:(NSString*)employeeGuid handler:(completionHandler)handler{
    NSString *urlPath = @"Attendance/search_sign_record_list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSDate *date = [NSDate date];
    NSUInteger dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    NSUInteger dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(dateFirstTime) forKey:@"begin_utc_time"];
    [params setObject:@(dateLastTime) forKey:@"end_utc_time"];
    [params setObject:@(1) forKey:@"page"];
    [params setObject:@(1000) forKey:@"size"];
    [params setObject:@(1) forKey:@"is_asc"];
    [params setObject:employeeGuid forKey:@"employee_guid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取公司的签到规则
+ (NSURLSessionDataTask*)getSiginRule:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/get_setting_list_v2";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//删除公司签到规则
+ (NSURLSessionDataTask*)deleteSiginRule:(NSString*)settingGuid handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/delete_setting_v2";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:settingGuid forKey:@"setting_guid"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//更新公司签到规则
+ (NSURLSessionDataTask*)updateSiginRule:(NSDictionary*)siginRule handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/update_setting_v2";
    NSMutableDictionary *params = [siginRule mutableCopy];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//添加公司签到规则
+ (NSURLSessionDataTask*)addSiginRule:(NSDictionary*)siginRule handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/setting_v2";
    NSMutableDictionary *params = [siginRule mutableCopy];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取指定年月异常签到记录
+ (NSURLSessionDataTask*)getUsualSigin:(NSString*)userGuid companyNo:(int)companyNo year:(int)year month:(int)month handler:(completionHandler)handler {
    NSString *urlPath = @"Attendance/get_exception_punchcard_records";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:userGuid forKey:@"user_guid"];
    [params setObject:@(year) forKey:@"year"];
    [params setObject:@(month) forKey:@"month"];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 会议
//创建会议
+ (NSURLSessionDataTask*)createMeet:(NSDictionary*)meetDic handler:(completionHandler)handler {
    NSString *urlPath = @"Meeting/add";
    NSMutableDictionary *params = [meetDic mutableCopy];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取会议室列表
+ (NSURLSessionDataTask*)getMeetRoomList:(int)companyNo handler:(completionHandler)handler {
    NSString *urlPath = @"Meeting/get_room_list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//根据传入时间获取会议室预约时间
+ (NSURLSessionDataTask*)getMeetHandlerTime:(int)roomId begin:(int64_t)begin end:(int64_t)end handler:(completionHandler)handler {
    NSString *urlPath = @"Meeting/get_handler_time";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(roomId) forKey:@"room_id"];
    [params setObject:@(begin) forKey:@"begin"];
    [params setObject:@(end) forKey:@"end"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取会议室时间空闲设备列表
+ (NSURLSessionDataTask*)getMeetEquipments:(int)companyNo begin:(int64_t)begin end:(int64_t)end handler:(completionHandler)handler {
    NSString *urlPath = @"Meeting/get_public_equipments";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(companyNo) forKey:@"company_no"];
    [params setObject:@(begin) forKey:@"begin"];
    [params setObject:@(end) forKey:@"end"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
#pragma mark -- 任务
//获取所有的任务数据
+ (NSURLSessionDataTask*)getTaskList:(NSString*)employeeGuid handler:(completionHandler)handler; {
    NSString *urlPath = @"Tasks/task_list_v3";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@(-1) forKey:@"status"];
    [params setObject:employeeGuid forKey:@"created_by"];
    [params setObject:employeeGuid forKey:@"in_charge"];
    [params setObject:employeeGuid forKey:@"member"];
    [params setObject:@(NSIntegerMax) forKey:@"end_date"];
    [params setObject:@(NSIntegerMax) forKey:@"page_size"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//创建任务
+ (NSURLSessionDataTask*)createTask:(NSDictionary*)taskDic handler:(completionHandler)handler {
    NSString *urlPath = @"Tasks/add_v3";
    NSMutableDictionary *params = [taskDic mutableCopy];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//上传任务附件
+ (NSURLSessionDataTask*)uploadAttachment:(NSString*)userGuid taskId:(int)taskId doc:(UIImage*)doc handler:(completionHandler)handler {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    NSDictionary *parameters = @{@"user_guid":userGuid,@"task_id":@(taskId),@"access_token":[IdentityManager manager].identity.accessToken};
    NSURLSessionDataTask * dataTask = [manager POST:@"Tasks/upload_attachment" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:[doc dataInNoSacleLimitBytes:MaXPicSize] name:@"doc" fileName:[NSString stringWithFormat:@"%@.jpg",@([NSDate date].timeIntervalSince1970 * 1000)] mimeType:@"image/jpeg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([responseObject[@"code"] integerValue] == 0) {
            handler(responseObject,nil);
        } else {
            handler(nil,[[MError alloc] initWithCode:task.error.code statsMsg:task.error.domain]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(nil,[[MError alloc] initWithCode:error.code statsMsg:error.domain]);
    }];
    
    [dataTask resume];
    return dataTask;
}
//获取任务详情
+ (NSURLSessionDataTask*)getTaskInfo:(int)taskId handler:(completionHandler)handler {
    NSString *urlPath = @"Tasks/task_info_v3";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(taskId) forKey:@"task_id"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取任务附件列表
+ (NSURLSessionDataTask*)getTaskAttachment:(int)taskId handler:(completionHandler)handler {
    NSString *urlPath = @"Tasks/attachment_list";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(taskId) forKey:@"task_id"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//删除任务附件
+ (NSURLSessionDataTask*)delTaskAttachment:(int)attachmentId handler:(completionHandler)handler {
    NSString *urlPath = @"Tasks/delete_attachment";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(attachmentId) forKey:@"id"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//获取任务评论列表
+ (NSURLSessionDataTask*)getTaskComment:(int)taskId handler:(completionHandler)handler {
    NSString *urlPath = @"Tasks/comment_list";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(taskId) forKey:@"task_id"];
    [params setObject:@(10000) forKey:@"page_size"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_GET URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//添加评论
+ (NSURLSessionDataTask*)addTaskComment:(int)taskId taskStatus:(int)taskStatus comment:(NSString*)comment createdby:(NSString*)createdby createdRealname:(NSString*)createdRealname handler:(completionHandler)handler {
    NSString *urlPath = @"Tasks/comment";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(taskId) forKey:@"task_id"];
    [params setObject:@(taskStatus) forKey:@"task_status"];
    [params setObject:comment forKey:@"comment"];
    [params setObject:createdby forKey:@"createdby"];
    [params setObject:createdRealname forKey:@"created_realname"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
//更新任务状态和原因
+ (NSURLSessionDataTask*)updateTask:(int)taskId status:(int)status comment:(NSString*)comment updatedby:(NSString*)updatedby handler:(completionHandler)handler {
    NSString *urlPath = @"Tasks/update_state";
    NSMutableDictionary *params = [@{} mutableCopy];
    [params setObject:@(taskId) forKey:@"id"];
    [params setObject:@(status) forKey:@"status"];
    [params setObject:comment forKey:@"comment"];
    [params setObject:updatedby forKey:@"updatedby"];
    [params setObject:[IdentityManager manager].identity.accessToken forKey:@"access_token"];
    completionHandler compleionHandler = ^(id data,MError *error) {
        handler(data,error);
    };
    return [[HttpService service] sendRequestWithHttpMethod:E_HTTP_REQUEST_METHOD_POST URLPath:urlPath parameters:params completionHandler:compleionHandler];
}
@end
