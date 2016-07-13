//
//  Company.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>

@interface Company : RLMObject

@property (nonatomic, strong) NSString *admin_user_guid;//管理员guid
@property (nonatomic, strong) NSString *company_name;//圈子名称
@property (nonatomic, assign) int company_no;//圈子编号
@property (nonatomic, assign) int company_type;//圈子类型
@property (nonatomic, assign) int is_default_company;//是不是默认的圈子
@property (nonatomic, strong) NSString *logo;//logoURL地址

@end