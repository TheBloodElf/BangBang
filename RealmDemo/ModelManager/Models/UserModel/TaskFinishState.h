//
//  TaskFinishState.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/15.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>
//任务完成情况
@interface TaskFinishState : RLMObject

@property (nonatomic, assign) int id;//唯一标识符
@property (nonatomic, assign) int task_id;//任务id
@property (nonatomic, assign) int beginStatus;//任务提交前状态
@property (nonatomic, assign) int endStatus;//任务提交后状态
@property (nonatomic, assign) int64_t createdon_utc;//提交时间
@property (nonatomic, strong) NSString *content;//提交内容
@property (nonatomic, strong) NSString *create_realname;//创建人真实名字
@property (nonatomic, strong) NSString *createdby;//创建人guid

@end

RLM_ARRAY_TYPE(TaskFinishState)