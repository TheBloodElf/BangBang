//
//  Calendar.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>
//日程
@interface Calendar : RLMObject

/** 事务编号 */
@property (nonatomic, assign) int64_t id;
/** 当前工作圈编号，如果没有输入0 */
@property (nonatomic, assign) int  company_no;
/** 事务名称 */
@property (nonatomic, strong) NSString      * event_name;
/** 事务描述 */
@property (nonatomic, strong) NSString   *descriptionStr;
/** 地点，如：成都 */
@property (nonatomic, strong) NSString      * address;
/** 开始时间 毫秒 */
@property (nonatomic, assign) int64_t    begindate_utc;
/** 结束时间 毫秒 */
@property (nonatomic, assign) int64_t    enddate_utc;
/** 是否全天事件 */
@property (nonatomic, assign) bool          is_allday;
/** 应用编号（如果是某个应该推送过来的，填写该项。如“任务”推送过来的） */
@property (nonatomic, strong) NSString      * app_guid;
/** 应用表的主键（如果是某个应该推送过来的，填写该项。如“任务”推送过来的，就填写任务的id） */
@property (nonatomic, strong) NSString      * target_id;
/** 重复周期类型：不重复-0,按天-1，按周-2，按月-3，按年-4 */
@property (nonatomic, assign) int   repeat_type;
/** 是否提醒 */
@property (nonatomic, assign) bool          is_alert;
/** 提前多少分钟提醒（1,2,5,10,15,20,25,30,45,60,90,120分钟） */
@property (nonatomic, assign) int      alert_minutes_before;
/** 结束后多少分钟提醒（1,2,5,10,15,20,25,30,45,60,90,120分钟） */
@property (nonatomic, assign) int     alert_minutes_after;
/** 用户唯一标识 */
@property (nonatomic, strong) NSString      * user_guid;
/** 创建者user_guid */
@property (nonatomic, strong) NSString      * created_by;
/** 创建时间 */
@property (nonatomic, assign) int64_t     createdon_utc;
/** 更新user_guid */
@property (nonatomic, strong) NSString      * updated_by;
/**  */
@property (nonatomic, assign) int64_t      updatedon_utc;
/** 0-已删除，1-正常，2-已完成 3-本地正常 4-本地已完成*/
@property (nonatomic, assign) int status;
/**  */
@property (nonatomic, assign) int64_t     finishedon_utc;
/**
 *  RRule字符串
 */
@property (nonatomic, strong) NSString *rrule;
@property (nonatomic, strong) NSString *rdate;
/**
 *  日程的紧急程度 0普通 1紧急 2非常紧急
 */
@property (nonatomic,assign) int emergency_status;
//周期性已删除日期
@property (nonatomic,strong) NSString   *deleted_dates;
//周期性已完成日期
@property (nonatomic,strong) NSString   *finished_dates;

/**
 *  有重复周期的开始时间
 */
@property(nonatomic,assign) int64_t r_begin_date_utc;
/**
 *  重复周期结束时间
 */
@property(nonatomic,assign) int64_t r_end_date_utc;

/**
 *  是否是跨天事件
 */
@property(nonatomic,assign) bool is_over_day;

/**
 *  分享用户的user_guid,逗号分隔
 */
@property(nonatomic,strong) NSString *members;
/**
 *  分享用户的姓名，逗号分隔
 */
@property(nonatomic,strong) NSString *member_names;
/**
 *  分享日程的唯一标识
 */
@property(nonatomic,strong) NSString *event_guid;
/**
 *  创建者姓名
 */
@property(nonatomic,strong) NSString *creator_name;

//是否有这个删除时间
- (BOOL)haveDeleteDate:(NSDate*)date;
//是否有这个完成时间
- (BOOL)haveFinishDate:(NSDate*)date;

@end
