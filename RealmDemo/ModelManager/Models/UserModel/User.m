//
//  User.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSString*)primaryKey {
    return @"user_guid";
}
- (instancetype)initWithJsonDic:(NSDictionary*)dic {
    if(self = [super init]) {
        self.QQ = dic[@"QQ"];
        self.avatar = dic[@"avatar"];
        self.email = dic[@"email"];
        self.id = [dic[@"id"] intValue];
        self.mobile = dic[@"mobile"];
        self.mood = dic[@"mood"];
        self.real_name = dic[@"real_name"];
        self.sex = [dic[@"sex"] intValue];
        self.user_guid = dic[@"user_guid"];
        self.user_name = dic[@"user_name"];
        self.user_no = [dic[@"user_no"] intValue];
        self.weixin = dic[@"weixin"];
    }
    return self;
}
+ (User*)copyFromUser:(User*)user {
    User *tempUser = [User new];
    tempUser.QQ = user.QQ;
    tempUser.avatar = user.avatar;
    tempUser.email = user.email;
    tempUser.id = user.id;
    tempUser.mobile = user.mobile;
    tempUser.mood = user.mood;
    tempUser.real_name = user.real_name;
    tempUser.sex = user.sex;
    tempUser.user_guid = user.user_guid;
    tempUser.user_name = user.user_name;
    tempUser.user_no = user.user_no;
    tempUser.weixin = user.weixin;
    if(user.currCompany) {
        Company *company = [Company new];
        company.admin_user_guid = user.currCompany.admin_user_guid;
        company.company_name = user.currCompany.company_name;
        company.company_no = user.currCompany.company_no;
        company.company_type = user.currCompany.company_type;
        company.is_default_company = user.currCompany.is_default_company;
        company.logo = user.currCompany.logo;
        tempUser.currCompany = company;
    }
    return tempUser;
}
@end
