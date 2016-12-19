//
//  PushMessage.h
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

//推送消息
@interface PushMessage : RLMObject
//#BANG-493 本地推送消息也要显示在消息栏
//解决思路：
//1：之前是收到本地推送才把消息加入到Message数据库中，现在是添加本地推送的时间直接把消息加入到Message数据库中，然后读取的时候读取触发时间在当前之前的数据显示出来；远程推送是收到才添加
//2：清空通知则只需要把本地已经触发的和远程推送删除即可
//3：重新添加本地推送只需要把没有触发的本地推送删除即可
//主键（时间戳 单位秒）  本地推送为正数  远程推送为负数
@property (nonatomic, strong) NSString* id;

@property (nonatomic, strong) NSString* target_id;

/*
 @"微圈通知",@"任务通知",@"请示提醒通知",@"审批提醒通知",@"系统通知",@"日程提醒通知",@"日程通知",@"任务提醒通知",@"任务讨论通知",@"邮件提醒",@"会议通知",@"投票通知",@"公告",@"通用审批提醒通知",@"工单通知"
@"COMPANY",@"TASK",@"REQUEST",@"NEW_APPROVAL",@"SYSTEM",@"CALENDARTIP",@"CALENDAR",@"TASKTIP",@"TASK_COMMENT_STATUS",@"MAIL",@"MEETING",@"VOTE",@"NOTICE",@"APPROVAL",@"WORK_ORDER"
 */
@property (nonatomic,strong) NSString *type;

@property (nonatomic,strong) NSString *content;//内容

@property (nonatomic,strong) NSString *icon;

@property (nonatomic,strong) NSDate *addTime;//远程推送到达时间  本地推送触发时间

@property (nonatomic,assign) int company_no;

@property (nonatomic,assign) int from_user_no;

@property (nonatomic,assign) int to_user_no;

@property (nonatomic,assign) bool unread;

//0-GENERAL 1-COMPANY_ALLOW_JOIN 2-COMPANY_REFUSE_JOIN 3-COMPANY_ALLOW_LEAVE 4-COMPANY_REFUSE_ LEAVE 5-COMPANY_ TRANSFER 6-CHANGE_PASSWORD
@property (nonatomic,strong) NSString *action;
@property (nonatomic,strong) NSString *entity;

- (NSString*)unreadImageName;//未读图片名称
- (NSString*)readImageName;//已读的图片名称
- (NSString*)typeString;//类型中文名字

@end
