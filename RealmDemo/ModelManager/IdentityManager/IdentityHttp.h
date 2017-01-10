//
//  IdentityHttp.h
//  RealmDemo
//
//  Created by Mac on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpService.h"

@interface IdentityHttp : NSObject

//获取accessToken
+ (NSURLSessionDataTask*)getAccessTokenhandler:(completionHandler)handler;
//系统账号密码登陆
+ (NSURLSessionDataTask*)loginWithEmail:(NSString*)email password:(NSString*)password handler:(completionHandler)handler;
//根据accessToken获取qq的uuid
+ (NSURLSessionDataTask*)getQqUuidWithToken:(NSString*)accessToken handler:(completionHandler)handler;
//社会化登录
//QQ = 1, WeChat = 2, Weibo = 3
+ (NSURLSessionDataTask*)socialLogin:(NSString *)social_id unionId:(NSString*)union_id media_type:(int)media_type token:(NSString *)token expires_in:(NSString *)expires_in client_type:(NSString *)client_type name:(NSString *)name avatar_url:(NSString *)avatar_url handler:(completionHandler)handler;
//获取在AppStore中的版本号
+ (NSURLSessionDataTask*)getSoftVersionHandler:(completionHandler)handler;

@end
