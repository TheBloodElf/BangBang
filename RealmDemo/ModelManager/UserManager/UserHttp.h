//
//  UserHttp.h
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpService.h"
#import "User.h"

@interface UserHttp : NSObject
#pragma mark -- 融云
//同步群组
+ (NSURLSessionDataTask*)syncRYGroup:(int)userNo handler:(completionHandler)handler;
//获取融云token
+ (NSURLSessionDataTask*)getRYToken:(int)userNo handler:(completionHandler)handler;
//将员工加入群聊
+ (NSURLSessionDataTask*)joinRYGroup:(int)userNo companyNo:(int)companyNo handler:(completionHandler)handler;
//将员工移除群聊
+ (NSURLSessionDataTask*)quitRYGroup:(int)userNo companyNo:(int)companyNo handler:(completionHandler)handler;
#pragma mark -- 邀请链接
//获取分享链接
+ (NSURLSessionDataTask*)getInviteURL:(int)userNo companyNo:(int)companyNo handler:(completionHandler)handler;
//获取推广链接
+ (NSURLSessionDataTask*)getReferrerURL:(int)userNo handler:(completionHandler)handler;
#pragma mark -- 修改用户信息
+ (NSURLSessionDataTask*)updateUserInfo:(User*)user handler:(completionHandler)handler;
#pragma mark -- 工作圈
//转让工作圈
+ (NSURLSessionDataTask*)transCompany:(int)companyNo ownerGuid:(NSString*)ownerGuid toGuid:(NSString*)toGuid handler:(completionHandler)handler;
//加入工作圈
+ (NSURLSessionDataTask*)joinCompany:(int)companyNo userGuid:(NSString*)userGuid joinReason:(NSString*)joinReason handler:(completionHandler)handler;
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
//获取工作圈创建者信息
+ (NSURLSessionDataTask*)getCompanyOwner:(int)companyNo handler:(completionHandler)handler;
//更新员工状态 如果在圈子中 那么退出圈子都是调的这个方法
+ (NSURLSessionDataTask*)updateEmployeeStatus:(NSString*)employeeGuid status:(int)status reason:(NSString*)reason handler:(completionHandler)handler;
@end
