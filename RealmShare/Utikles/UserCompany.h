//
//  UserCompany.h
//  RealmDemo
//
//  Created by Mac on 16/7/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserCompany : NSObject

@property (nonatomic, strong) NSString *admin_user_guid;//管理员guid
@property (nonatomic, strong) NSString *company_name;//圈子名称
@property (nonatomic, assign) int company_no;//圈子编号
/**非必填，默认为6。 1-国有企业 2-私有企业 3-事业单位或社会团体 4-中外合资 5-外商独资 6-其他 */
@property (nonatomic, assign) int company_type;//圈子类型
@property (nonatomic, assign) int is_default_company;//是不是默认的圈子
@property (nonatomic, strong) NSString *logo;//logoURL地址

@end
