//
//  PushMessage.h
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>

@interface PushMessage : RLMObject

@property (nonatomic,strong) NSString *target_id;

//1-COMPANY,2-TASK,3-REQUEST,4-APPROVAL,5-SYSTEM,6-CALENDAR,7-TASKTIP,8-TASK_COMMENT_STATUS 9 -MAIL 10 -MEETING
@property (nonatomic,strong) NSString *type;

@property (nonatomic,strong) NSString *content;

@property (nonatomic,strong) NSString *icon;

@property (nonatomic,strong) NSString *time;

@property (nonatomic,strong) NSString *company_no;

@property (nonatomic,strong) NSString *from_user_no;

@property (nonatomic,strong) NSString *to_user_no;

@property (nonatomic,assign) bool unread;

//0-GENERAL 1-COMPANY_ALLOW_JOIN 2-COMPANY_REFUSE_JOIN 3-COMPANY_ALLOW_LEAVE 4-COMPANY_REFUSE_ LEAVE 5-COMPANY_ TRANSFER 6-CHANGE_PASSWORD
@property (nonatomic,strong) NSString *action;
@property (nonatomic,strong) NSString *entity;

@end
