//
//  TaskCommentModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//讨论信息
@interface TaskCommentModel : NSObject

@property (nonatomic, assign) int id;//主键
@property (nonatomic, assign) int task_id;//任务编号
@property (nonatomic, assign) int task_status;//任务状态(冗余)
@property (nonatomic, assign) int comment_id;//被回复的评论编号，没有为0
@property (nonatomic, assign) int status;//评论状态 0-已删除，1-进行中，2-被禁言
@property (nonatomic, assign) int64_t createdon_utc;//评论时间

@property (nonatomic, strong) NSString *comment;//内容
@property (nonatomic, strong) NSString *reply_employeeguid;//被回复的员工编号
@property (nonatomic, strong) NSString *reply_employeename;//被回复的员工姓名
@property (nonatomic, strong) NSString *created_by;//created_by
@property (nonatomic, strong) NSString *created_realname;//created_realname
@property (nonatomic, strong) NSString *avatar;//avatar

@end
