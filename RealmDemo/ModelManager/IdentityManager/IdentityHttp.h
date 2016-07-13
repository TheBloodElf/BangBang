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
//第三方登陆
+ (NSURLSessionDataTask*)regWithphone:(NSString *)phone password:(NSString *)password confirm_password:(NSString *)confirm_password real_name:(NSString *)real_name captcha:(NSString *)captcha handler:(completionHandler)handler;
@end
