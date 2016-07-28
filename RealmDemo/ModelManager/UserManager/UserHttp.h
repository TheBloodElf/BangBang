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
#import "Calendar.h"
#import "SignIn.h"

@interface UserHttp : NSObject
#pragma mark -- 上传图片
//上传图片 得到地址
+ (NSURLSessionDataTask*)updateImageGuid:(NSString*)guid image:(UIImage*)image handler:(completionHandler)handler;
#pragma mark -- 社会化登录
+ (NSURLSessionDataTask*)socialLogin:(NSString *)social_id
                          media_type:(NSString *)media_type
                               token:(NSString *)token
                          expires_in:(NSString *)expires_in
                         client_type:(NSString *)client_type
                                name:(NSString *)name
                          avatar_url:(NSString *)avatar_url handler:(completionHandler)handler;
#pragma mark -- 个推
//绑定个推别名
+ (NSURLSessionDataTask*)setupAPNSDevice:(NSString*)clientId userNo:(int)userNo handler:(completionHandler)handler;
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
#pragma mark -- 讨论组
//获取用户通讯录中的讨论组
+ (NSURLSessionDataTask*)getUserDiscuss:(int)userNo handler:(completionHandler)handler;
//添加讨论组
+ (NSURLSessionDataTask*)addUserDiscuss:(int)userNo discussId:(NSString*)discussId discussTitle:(NSString*)discussTitle handler:(completionHandler)handler;
//删除讨论组
+ (NSURLSessionDataTask*)delUserDiscuss:(int)userNo discussId:(NSString*)discussId handler:(completionHandler)handler;
#pragma mark -- 日程
//创建日程
+ (NSURLSessionDataTask*)createUserCalendar:(Calendar*)calendar handler:(completionHandler)handler;
//修改日程
+ (NSURLSessionDataTask*)updateUserCalendar:(Calendar*)calendar handler:(completionHandler)handler;
//获取用户所有日程
+ (NSURLSessionDataTask*)getUserCalendar:(NSString*)userGuid handler:(completionHandler)handler;
#pragma mark -- 签到
//提交签到信息
+ (NSURLSessionDataTask*)sigin:(SignIn*)sigin handler:(completionHandler)handler;
//获取今天的签到记录
+ (NSURLSessionDataTask*)getSiginList:(int)companyNo employeeGuid:(NSString*)employeeGuid handler:(completionHandler)handler;
//获取公司的签到规则
+ (NSURLSessionDataTask*)getSiginRule:(int)companyNo handler:(completionHandler)handler;
//删除公司签到规则
+ (NSURLSessionDataTask*)deleteSiginRule:(NSString*)settingGuid handler:(completionHandler)handler;
//更新公司签到规则
+ (NSURLSessionDataTask*)updateSiginRule:(NSDictionary*)siginRule handler:(completionHandler)handler;
//添加公司签到规则
+ (NSURLSessionDataTask*)addSiginRule:(NSDictionary*)siginRule handler:(completionHandler)handler;
//获取指定年月异常签到记录
+ (NSURLSessionDataTask*)getUsualSigin:(NSString*)userGuid companyNo:(int)companyNo year:(int)year month:(int)month handler:(completionHandler)handler;
@end
