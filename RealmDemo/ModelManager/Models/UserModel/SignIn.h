//
//  SignIn.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/21.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>
/**
 *  签到记录模型
 */
@interface SignIn : RLMObject
/**
 *  唯一ID
 */
@property(nonatomic,assign)int id;
/**
 *  配置点的GUID
 */
@property(nonatomic,strong)NSString *setting_guid;
/**
 *  打卡者员工GUID
 */
@property(nonatomic,strong)NSString *employee_guid;
/**
 *  打卡者姓名
 */
@property(nonatomic,strong)NSString *create_name;
/**
 *  类型；0-上班；1-下班；2-外勤；3-其他
 */
@property(nonatomic,assign)int category;
/**
 *  打卡者头像
 */
@property(nonatomic,strong)NSString *create_avatar;
/**
 *  公司编号
 */
@property(nonatomic,assign)int company_no;
/**
 *  打卡员工GUID
 */
@property(nonatomic,strong)NSString *user_guid;
/**
 *  打卡时间
 */
@property(nonatomic,assign)int64_t create_on_utc;
/**
 *  签到详情
 */
@property(nonatomic,strong)NSString *descriptionStr;
/**
 *  经度
 */
@property(nonatomic,assign)CGFloat longitude;

/**
 *  纬度
 */
@property(nonatomic,assign)CGFloat latitude;

/**
 *  地址详情
 */
@property(nonatomic,strong)NSString *address;

/**
 *  签到点名称
 */
@property(nonatomic,strong)NSString *address_name;

/**
 *  国家
 */
@property(nonatomic,strong)NSString *country;

/**
 *  省
 */
@property(nonatomic,strong)NSString *province;

/**
 *  城市
 */
@property(nonatomic,strong)NSString *city;

/**
 *  街道小区
 */
@property(nonatomic,strong)NSString *subdistrict;

/**
 *  城市编号（区号）
 */
@property(nonatomic,assign)int city_code;

/**
 *
 区域编码（邮编）
 */
@property(nonatomic,assign)int area_code;

/**
 *  精度
 */
@property(nonatomic,assign) CGFloat precision;

/**
 *  附件列表，已“;”分割
 */
@property(nonatomic,strong) NSString *attachments;

/**
 *  距离
 */
@property(nonatomic,assign)double distance;

/**
 *  是否有效 迟到早退算无效
 */
@property(nonatomic, assign)BOOL validity;

- (NSString*)categoryStr;

@end
