//
//  PushMessage.h
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>
//推送消息
@interface PushMessage : RLMObject

@property (nonatomic,strong) NSString *target_id;

/*
 @"微圈通知",@"任务通知",@"请示提醒通知",@"审批提醒通知",@"系统通知",@"日程提醒通知",@"日程通知",@"任务提醒通知",@"任务讨论通知",@"邮件提醒",@"会议通知",@"投票通知",@"公告",@"通用审批提醒通知",@"工单通知"
@"COMPANY",@"TASK",@"REQUEST",@"NEW_APPROVAL",@"SYSTEM",@"CALENDARTIP",@"CALENDAR",@"TASKTIP",@"TASK_COMMENT_STATUS",@"MAIL",@"MEETING",@"VOTE",@"NOTICE",@"APPROVAL",@"WORK_ORDER"
 */
@property (nonatomic,strong) NSString *type;

@property (nonatomic,strong) NSString *content;//内容

@property (nonatomic,strong) NSString *icon;

@property (nonatomic,strong) NSDate *addTime;//添加时间

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
- (CGFloat)contentHeight:(CGFloat)width font:(int)font;//在这个宽度和字体下内容占的高度

@end
