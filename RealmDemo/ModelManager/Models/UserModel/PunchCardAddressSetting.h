//
//  PunchCardAddressSetting.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/22.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>

@interface PunchCardAddressSetting : RLMObject


@property (nonatomic, assign) NSInteger id;//主键
@property (nonatomic, strong) NSString *setting_guid;//地址GUID 删除数据库时按照这个删除
@property (nonatomic, assign) NSInteger company_no;//圈子编号
@property (nonatomic, copy) NSString *address_guid;//地址guid，唯一标示
@property (nonatomic, assign) int setting_id;//地址id，唯一标示
@property (nonatomic, copy) NSString *name;//CELL上面的名字
@property (nonatomic, assign) double longitude;//签到位置,经度
@property (nonatomic, assign) double latitude;//签到位置,纬度
@property (nonatomic, copy) NSString *country;//签到点设置国家
@property (nonatomic, copy) NSString *province;//签到点设置省份
@property (nonatomic, copy) NSString *city;//签到点设置城市
@property (nonatomic, copy) NSString *subdistrict;//签到点街道
@property (nonatomic, copy) NSString *address;// 综合信息

@property (nonatomic, copy)  NSString *create_by;//创建人员的员工ID
@property (nonatomic, copy)  NSString *user_guid;//创建人用户GUID
@property (nonatomic, assign) int64_t create_on_utc;//签到规则创建时间
@property (nonatomic, copy) NSString *update_by;//更新签到规则的员工ID
@property (nonatomic, assign) int64_t update_on_utc;//签到规则更新时间  修改签到规则界面要使用
- (instancetype)initWithAMapPOI:(AMapPOI*)aMapPOI;

@end

RLM_ARRAY_TYPE(PunchCardAddressSetting)