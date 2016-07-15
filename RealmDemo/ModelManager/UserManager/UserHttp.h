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
#pragma mark -- 工作圈
//创建工作圈
+ (NSURLSessionDataTask*)createCompany:(NSString*)companyName userGuid:(NSString*)userGuid image:(UIImage*)image companyType:(int)companyType handler:(completionHandler)handler;
//获取圈子员工列表
+ (NSURLSessionDataTask*)getEmployeeCompnyNo:(int)companyNo status:(int)status userGuid:(NSString*)userGuid handler:(completionHandler)handler;
//获取用户所在工作圈
+ (NSURLSessionDataTask*)getCompanysUserGuid:(NSString*)userGuid handler:(completionHandler)handler;
//修改工作圈信息
+ (NSURLSessionDataTask*)updateCompany:(int)companyNo companyName:(NSString*)companyName companyType:(int)companyType logo:(NSString*)logo handler:(completionHandler)handler;
//获取工作圈列表
+ (NSURLSessionDataTask*)getCompanyList:(NSString*)companyName pageSize:(int)pageSize pageIndex:(int)pageIndex handler:(completionHandler)handler;
@end
