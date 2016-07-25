//
//  SiginRuleSet.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/22.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>
#import "PunchCardAddressSetting.h"

@interface SiginRuleSet : RLMObject

@property (nonatomic, assign) NSInteger id;//主键
@property (nonatomic, assign) NSInteger scope;//误差范围 单位米
@property (nonatomic, assign) CGFloat longitude;//签到位置,经度
@property (nonatomic, assign) CGFloat latitude;//签到位置,纬度
@property (nonatomic, copy) NSString *address;// 综合信息
@property (nonatomic, assign) NSInteger start_work_time;//上班时间 时间戳 单位秒
@property (nonatomic, assign) NSInteger end_work_time;//下班时间 时间戳 单位秒
@property (nonatomic, assign) NSInteger company_no;//圈子编号
@property (nonatomic, copy) NSString *create_by;//创建人员的员工ID
@property (nonatomic, copy) NSString *user_guid;//创建人用户GUID
@property (nonatomic, copy) NSString *country;//签到点设置国家
@property (nonatomic, copy) NSString *province;//签到点设置省份
@property (nonatomic, copy) NSString *city;//签到点设置城市
@property (nonatomic, copy) NSString *subdistrict;//签到点街道
@property (nonatomic, copy) NSString *setting_name;//签到规则别名
@property (nonatomic, copy) NSString *setting_guid;//添加时此字段不赋值，签到点唯一编号
@property (nonatomic, assign) NSInteger create_on_utc;//签到规则创建时间
@property (nonatomic, assign) NSInteger update_on_utc;//签到规则更新时间  修改签到规则界面要使用
@property (nonatomic, copy) NSString *work_day;//对应的工作日 1 2 3 4 5
@property (nonatomic, assign) NSInteger is_alert;//是否提醒,此处为True则StartWorkTimeAlert、EndWorkTimeAlert方可生效
@property (nonatomic, assign) NSInteger start_work_time_alert;//上班提醒时间 单位分
@property (nonatomic, assign) NSInteger end_work_time_alert;//下班提醒时间 单位分
@property (nonatomic, strong) NSString *update_by;//更新签到规则的员工ID
@property (nonatomic , strong) RLMArray<PunchCardAddressSetting> *json_list_address_settings;//设置的签到点位置

+ (instancetype)conpyFromSiginRuleSet:(SiginRuleSet*)siginRuleSet;
- (instancetype)initWithJsonDic:(NSDictionary*)dic;

@end
