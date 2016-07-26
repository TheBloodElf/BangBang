//
//  SiginRuleSet.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/22.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SiginRuleSet.h"

@implementation SiginRuleSet

+ (NSString*)primaryKey {
    return @"id";
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"json_list_address_settings":@"PunchCardAddressSetting"};
}
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"json_list_address_settings":@"address_settings"};
}
+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"longitude",@"latitude",@"update_by"];
}
+ (instancetype)conpyFromSiginRuleSet:(SiginRuleSet*)siginRuleSet {
    SiginRuleSet *temp = [SiginRuleSet new];
    temp.id = siginRuleSet.id;
    temp.scope = siginRuleSet.scope;
    temp.longitude = siginRuleSet.longitude;
    temp.latitude = siginRuleSet.latitude;
    temp.address = siginRuleSet.address;
    temp.start_work_time = siginRuleSet.start_work_time;
    temp.end_work_time = siginRuleSet.end_work_time;
    temp.company_no = siginRuleSet.company_no;
    temp.create_by = siginRuleSet.create_by;
    temp.user_guid = siginRuleSet.user_guid;
    temp.country = siginRuleSet.country;
    temp.province = siginRuleSet.province;
    temp.city = siginRuleSet.city;
    temp.subdistrict = siginRuleSet.subdistrict;
    temp.setting_name = siginRuleSet.setting_name;
    temp.setting_guid = siginRuleSet.setting_guid;
    temp.create_on_utc = siginRuleSet.create_on_utc;
    temp.update_on_utc = siginRuleSet.update_on_utc;
    temp.work_day = siginRuleSet.work_day;
    temp.is_alert = siginRuleSet.is_alert;
    temp.start_work_time_alert = siginRuleSet.start_work_time_alert;
    temp.end_work_time_alert = siginRuleSet.end_work_time_alert;
    temp.update_by = siginRuleSet.update_by;
    NSMutableArray *array = [@[] mutableCopy];
    for (PunchCardAddressSetting *temp in siginRuleSet.json_list_address_settings) {
        [array addObject:[[PunchCardAddressSetting alloc] initWithJSONDictionary:[temp JSONDictionary]]];
    }
    temp.json_list_address_settings = (id)array;
    return temp;
}
@end
