//
//  Company.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//
@class Employee;
//圈子
//这里要注意：只存当前用户在此圈子中状态为在职或者申请离职的  其他状态的不存
@interface Company : RLMObject

@property (nonatomic, strong) NSString *admin_user_guid;//管理员guid
@property (nonatomic, strong) NSString *company_name;//圈子名称
@property (nonatomic, assign) int company_no;//圈子编号
/**非必填，默认为6。 1-国有企业 2-私有企业 3-事业单位或社会团体 4-中外合资 5-外商独资 6-其他 */
@property (nonatomic, assign) int company_type;//圈子类型
@property (nonatomic, assign) int is_default_company;//是不是默认的圈子
@property (nonatomic, strong) NSString *logo;//logoURL地址

- (NSString*)companyTypeStr;//圈子类型


@end