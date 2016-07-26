//
//  PunchCardAddressSetting.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/22.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "PunchCardAddressSetting.h"
#import "UserManager.h"

@implementation PunchCardAddressSetting

+ (NSString*)primaryKey {
    return @"id";
}
+ (NSArray *)mj_ignoredPropertyNames {
    return @[@"update_by"];
}
- (instancetype)initWithAMapPOI:(AMapPOI*)aMapPOI
{
    if (self = [super init]) {
        UserManager *userManager = [UserManager manager];
        Employee *employee = [userManager getEmployeeWithGuid:userManager.user.user_guid companyNo:userManager.user.currCompany.company_no];
        self.company_no = userManager.user.currCompany.company_no;
        self.name = aMapPOI.name;
        self.latitude = aMapPOI.location.latitude;
        self.longitude = aMapPOI.location.longitude;
        self.province = aMapPOI.province;
        self.city = aMapPOI.city;
        self.address = aMapPOI.address;
        self.subdistrict = aMapPOI.district;
        self.create_by = employee.employee_guid;
        self.user_guid = userManager.user.user_guid;
        self.update_by = employee.employee_guid;
    }
    return self;
}

@end
