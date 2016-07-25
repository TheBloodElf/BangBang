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
- (instancetype)initWithJsonDic:(NSDictionary*)dic {
    if(self = [super init]) {
        self.id = [dic[@"id"] integerValue];
        self.scope = [dic[@"scope"] integerValue];
        self.longitude = [dic[@"longitude"] integerValue];
        self.latitude = [dic[@"latitude"] integerValue];
        self.address = dic[@"address"];
        self.start_work_time = [dic[@"start_work_time"] integerValue];
        self.end_work_time = [dic[@"end_work_time"] integerValue];
        self.company_no = [dic[@"company_no"] integerValue];
        self.create_by = dic[@"create_by"];
        self.user_guid = dic[@"user_guid"];
        self.country =  dic[@"country"];
        self.province =  dic[@"province"];
        self.city =  dic[@"city"];
        self.subdistrict =  dic[@"subdistrict"];
        self.setting_name =  dic[@"setting_name"];
        self.setting_guid =  dic[@"setting_guid"];
        self.create_on_utc =  [dic[@"create_on_utc"] integerValue];
        self.update_on_utc =  [dic[@"update_on_utc"] integerValue];
        self.work_day = [dic[@"work_day"] componentsJoinedByString:@","];
        self.is_alert =  [dic[@"is_alert"] integerValue];
        self.start_work_time_alert = [dic[@"start_work_time_alert"] integerValue];
        self.end_work_time_alert = [dic[@"end_work_time_alert"] integerValue];
        self.update_by = dic[@"update_by"];
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *temp in dic[@"json_list_address_settings"]) {
            PunchCardAddressSetting *setting = [PunchCardAddressSetting new];
            [setting mj_setKeyValues:temp];
            [array addObject:temp];
        }
        self.json_list_address_settings = (id)array;
    }
    return self;
}
@end
