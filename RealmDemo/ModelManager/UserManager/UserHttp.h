//
//  UserHttp.h
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpService.h"

@interface UserHttp : NSObject
//创建工作圈
+ (NSURLSessionDataTask*)createCompany:(NSString*)company_name company_type:(NSString*)company_type hasImage:(UIImage*)hasImage handler:(completionHandler)handler;
@end
