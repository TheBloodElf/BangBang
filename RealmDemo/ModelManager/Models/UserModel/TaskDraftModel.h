//
//  TaskDraftModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/9/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskFinishState.h"
//任务草稿模型
@interface TaskDraftModel : RLMObject

@property (nonatomic, assign) int id;//任务编号
@property (nonatomic, strong) NSString *task_name;//任务名称
@property (nonatomic, strong) NSString *descriptionStr;//任务描述
@property (nonatomic, assign) int64_t begindate_utc;//开始时间
@property (nonatomic, assign) int64_t enddate_utc;//结束时间
@property (nonatomic, strong) NSString *incharge;//负责人员工编号employee_guid
@property (nonatomic, strong) NSString *incharge_name;//负责人名称
@property (nonatomic, assign) int status;//0-已删除，1-新建，2-进行中，4-待审批,6-审批拒绝,7-已完成,8-已终止
@property (nonatomic, strong) NSString *createdby;//创建者员工编号employee_guid
@property (nonatomic, strong) NSString *user_guid;//创建者注册用户唯一标识user_guid
@property (nonatomic, strong) NSString *avatar;//创建者头像
@property (nonatomic, strong) NSString *incharge_avatar;//负责人头像
@property (nonatomic, strong) NSString *create_realname;//创建者真实姓名
@property (nonatomic, assign) int company_no;//公司编号
@property (nonatomic, assign) int64_t createdon_utc;//创建时间
@property (nonatomic, strong) NSString *app_guid;//应用编号
@property (nonatomic, assign) int64_t acceptdate_utc;//接受时间
@property (nonatomic, assign) int64_t finishdate_utc;//完成时间
@property (nonatomic, assign) int64_t approvedate_utc;//审批通过时间
@property (nonatomic, assign) int64_t rejectdate_utc;//审批拒绝时间
@property (nonatomic, strong) NSString *finish_comment;//完成意见
@property (nonatomic, strong) NSString *approve_comment;//审批意见
@property (nonatomic, assign) int64_t updatedon_utc;//最后更新时间
@property (nonatomic, strong) NSString *updatedby;//最后更新者employee_guid

@property (nonatomic, strong) RLMArray<TaskFinishState> *taskFinishStateArr;//任务完成状态

@property (nonatomic, assign) int creator_unread_commentcount;//创建者看到的该任务未读评论数量
@property (nonatomic, assign) int incharge_unread_commentcount;//负责人看到的该任务未读评论数量
@property (nonatomic, assign) int creator_unread_attachcount;//创建者看到的该任务未读附件数量
@property (nonatomic, assign) int incharge_unread_attachcount;//负责人看到的该任务未读附件数量
@property (nonatomic, assign) int attachment_count;//附件数量
@property (nonatomic, strong) NSString *members_avatar;//知悉人头像，已","隔开
@property (nonatomic, strong) NSString *members;//知悉人GUID，已","隔开
@property (nonatomic, strong) NSString *member_realnames;//知悉人姓名，已","隔开
@property (nonatomic, strong) NSString *alert_date_list;//提醒时间列表,已","隔开

@property (nonatomic, strong) NSMutableArray<NSData*> *attachmentArr;//附件数组

@end
