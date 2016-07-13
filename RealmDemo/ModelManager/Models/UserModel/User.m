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
@end
