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

@end
