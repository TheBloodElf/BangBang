//
//  SelectEmployeeModel.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SelectEmployeeModel.h"

@implementation SelectEmployeeModel

- (instancetype)initWithEmployee:(Employee*)employee {
    if(self = [super init]) {
        self.user_guid = employee.user_guid;
        self.user_no = employee.user_no;
        self.email = employee.email;
        self.real_name = employee.real_name;
        self.user_real_name = employee.user_real_name;
        self.avatar = employee.avatar;
        self.mood = employee.mood;
        self.sex = employee.sex;
        self.mobile = employee.mobile;
        self.QQ = employee.QQ;
        self.weixin = employee.weixin;
        self.employee_guid = employee.employee_guid;
        self.join_reason = employee.join_reason;
        self.leave_reason = employee.leave_reason;
        self.status = employee.status;
        self.company_no = employee.company_no;
        self.created = employee.created;
        self.updated = employee.updated;
        self.user_name = employee.user_name;
    }
    return self;
}

@end
