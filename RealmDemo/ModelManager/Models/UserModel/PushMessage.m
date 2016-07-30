//
//  PushMessage.m
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "PushMessage.h"

#define pushMessageDic @{@"COMPANY":@{@"typeString":@"微圈通知",@"unreadImageName":@"pushMessage_circle.png",@"readImageName":@"pushMessage_circle1.png"},\
@"TASK":@{@"typeString":@"任务通知",@"unreadImageName":@"pushMessage_task.png",@"readImageName":@"pushMessage_task1.png"},\
@"REQUEST":@{@"typeString":@"请示提醒通知",@"unreadImageName":@"pushMessage_approve.png",@"readImageName":@"pushMessage_approve1.png"},\
@"NEW_APPROVAL":@{@"typeString":@"审批提醒通知",@"unreadImageName":@"pushMessage_approve.png",@"readImageName":@"pushMessage_approve1.png"},\
@"SYSTEM":@{@"typeString":@"系统通知",@"unreadImageName":@"ic_notice_system.png",@"readImageName":@"ic_notice_system1.png"},\
@"CALENDARTIP":@{@"typeString":@"日程提醒通知",@"unreadImageName":@"pushMessage_schedule.png",@"readImageName":@"pushMessage_schedule1.png"},\
@"CALENDAR":@{@"typeString":@"日程通知",@"unreadImageName":@"pushMessage_schedule.png",@"readImageName":@"pushMessage_schedule1.png"},\
@"TASKTIP":@{@"typeString":@"任务提醒通知",@"unreadImageName":@"pushMessage_task.png",@"readImageName":@"pushMessage_task1.png"},\
@"TASK_COMMENT_STATUS":@{@"typeString":@"任务讨论通知",@"unreadImageName":@"pushMessage_task.png",@"readImageName":@"pushMessage_task1.png"},\
@"MAIL":@{@"typeString":@"邮件提醒",@"unreadImageName":@"pushMessage_Email",@"readImageName":@"pushMessage_Email1"},\
@"MEETING":@{@"typeString":@"会议通知",@"unreadImageName":@"pushMessage_meeting",@"readImageName":@"pushMessage_meeting1"},\
@"VOTE":@{@"typeString":@"投票通知",@"unreadImageName":@"pushMessage_vote",@"readImageName":@"pushMessage_vote1"},\
@"NOTICE":@{@"typeString":@"公告",@"unreadImageName":@"pushMessage_announcement",@"readImageName":@"pushMessage_announcement1"},\
@"APPROVAL":@{@"typeString":@"通用审批提醒通知",@"unreadImageName":@"pushMessage_approve.png",@"readImageName":@"pushMessage_approve1.png"},\
@"WORK_ORDER":@{@"typeString":@"工单通知",@"unreadImageName":@"pushMessage_announcement.png",@"readImageName":@"pushMessage_announcement1.png"}}

@implementation PushMessage

+ (NSString*)primaryKey {
    return @"target_id";
}
- (NSString*)readImageName {
    NSString *type = self.type;
    NSDictionary *dic = pushMessageDic[type];
    return dic[@"readImageName"];
}
- (NSString*)unreadImageName {
    NSString *type = self.type;
    NSDictionary *dic = pushMessageDic[type];
    return dic[@"unreadImageName"];
}
- (NSString*)typeString {
    NSString *type = self.type;
    NSDictionary *dic = pushMessageDic[type];
    return dic[@"typeString"];
}
- (CGFloat)contentHeight:(CGFloat)width font:(int)font{
    return [self.content textSizeWithFont:[UIFont systemFontOfSize:font] constrainedToSize:CGSizeMake(width, 10000)].height;
}
@end
