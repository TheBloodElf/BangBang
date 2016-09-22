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
//上传图片 得到地址 网页上传用的
+ (NSURLSessionDataTask*)updateImageGuid:(NSString*)guid image:(UIImage*)image handler:(completionHandler)handler;
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
//修改用户信息
+ (NSURLSessionDataTask*)updateUserInfo:(User*)user handler:(completionHandler)handler;
//修改用户帮帮号
+ (NSURLSessionDataTask*)updateUserName:(NSString*)userGuid userName:(NSString*)userName handler:(completionHandler)handler;
//修改用户头像
+ (NSURLSessionDataTask*)updateUserAvater:(UIImage*)image userGuid:(NSString*)userGuid handler:(completionHandler)handler;
#pragma mark -- 工作圈
//获取工作圈信息
+ (NSURLSessionDataTask*)getCompanyInfo:(int)companyId handler:(completionHandler)handler;
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
//修改工作圈logo
+ (NSURLSessionDataTask*)updateConpanyAvater:(UIImage*)image companyNo:(int)companyNo userGuid:(NSString*)userGuid handler:(completionHandler)handler;
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
//同步日程
+ (NSURLSessionDataTask*)syncUserCalendar:(Calendar*)calendar handler:(completionHandler)handler;
//创建日程
+ (NSURLSessionDataTask*)createUserCalendar:(Calendar*)calendar handler:(completionHandler)handler;
//修改日程
+ (NSURLSessionDataTask*)updateUserCalendar:(Calendar*)calendar handler:(completionHandler)handler;
//删除日程
+ (NSURLSessionDataTask*)deleteUserCalendar:(int64_t)eventId handler:(completionHandler)handler;
//完成日程
+ (NSURLSessionDataTask*)finishUserCalendar:(Calendar*)calendar handler:(completionHandler)handler;
//添加日程完成时间
+ (NSURLSessionDataTask*)addCalendarFinishDate:(int64_t)eventID finishDate:(int64_t)finishDate handler:(completionHandler)handler;
//添加日程删除时间
+ (NSURLSessionDataTask*)addCalendarDeleteDate:(int64_t)eventID deleteDate:(int64_t)deleteDate handler:(completionHandler)handler;
//获取用户所有日程
+ (NSURLSessionDataTask*)getUserCalendar:(NSString*)userGuid handler:(completionHandler)handler;
#pragma mark -- 签到
//上传签到附件
+ (NSURLSessionDataTask*)uploadSiginPic:(UIImage*)image siginId:(int)siginId userGuid:(NSString*)userGuid companyNo:(int)companyNo handler:(completionHandler)handler;
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
#pragma mark -- 会议
//创建会议
+ (NSURLSessionDataTask*)createMeet:(NSDictionary*)meetDic handler:(completionHandler)handler;
//获取会议室列表
+ (NSURLSessionDataTask*)getMeetRoomList:(int)companyNo handler:(completionHandler)handler;
//根据传入时间获取会议室预约时间
+ (NSURLSessionDataTask*)getMeetHandlerTime:(int)roomId begin:(int64_t)begin end:(int64_t)end handler:(completionHandler)handler;
//获取会议室时间空闲设备列表
+ (NSURLSessionDataTask*)getMeetEquipments:(int)companyNo begin:(int64_t)begin end:(int64_t)end handler:(completionHandler)handler;
#pragma mark -- 任务
//获取圈子所有的任务数据
+ (NSURLSessionDataTask*)getTaskList:(NSString*)employeeGuid handler:(completionHandler)handler;
//创建任务
+ (NSURLSessionDataTask*)createTask:(NSDictionary*)taskDic handler:(completionHandler)handler;
//上传任务附件
+ (NSURLSessionDataTask*)uploadAttachment:(NSString*)userGuid taskId:(int)taskId doc:(UIImage*)doc handler:(completionHandler)handler;
//获取任务详情
+ (NSURLSessionDataTask*)getTaskInfo:(int)taskId handler:(completionHandler)handler;
//获取任务附件列表
+ (NSURLSessionDataTask*)getTaskAttachment:(int)taskId handler:(completionHandler)handler;
//删除任务附件
+ (NSURLSessionDataTask*)delTaskAttachment:(int)attachmentId handler:(completionHandler)handler;
//获取任务评论列表
+ (NSURLSessionDataTask*)getTaskComment:(int)taskId handler:(completionHandler)handler;
//添加评论
+ (NSURLSessionDataTask*)addTaskComment:(int)taskId taskStatus:(int)taskStatus comment:(NSString*)comment createdby:(NSString*)createdby createdRealname:(NSString*)createdRealname repEmployeeGuid:(NSString*)repEmployeeGuid repEmployeeName:(NSString*)repEmployeeName handler:(completionHandler)handler;
//更新评论状态为已读
+ (NSURLSessionDataTask*)updateTaskCommentStatus:(int)taskId employeeGuid:(NSString*)employeeGuid handler:(completionHandler)handler;
//更新任务状态和原因
+ (NSURLSessionDataTask*)updateTask:(int)taskId status:(int)status comment:(NSString*)comment updatedby:(NSString*)updatedby handler:(completionHandler)handler;
#pragma mark -- 应用中心
//获取应用列表
+ (NSURLSessionDataTask*)getCenterAppListHandler:(completionHandler)handler;
//获取我的应用
+ (NSURLSessionDataTask*)getMyAppList:(NSString*)userGuid handler:(completionHandler)handler;
//添加应用
+ (NSURLSessionDataTask*)addApp:(NSString*)userGuid appGuid:(NSString*)appGuid handler:(completionHandler)handler;
//删除应用
+ (NSURLSessionDataTask*)deleteApp:(NSString*)userGuid appGuid:(NSString*)appGuid handler:(completionHandler)handler;
@end
