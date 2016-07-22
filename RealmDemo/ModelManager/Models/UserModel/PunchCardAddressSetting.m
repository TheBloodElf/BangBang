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
+ (instancetype)conpyFromPunchCardAddressSetting:(PunchCardAddressSetting*)punchCardAddressSetting {
    PunchCardAddressSetting *temp = [PunchCardAddressSetting new];
    temp.id = punchCardAddressSetting.id;
    temp.setting_guid = punchCardAddressSetting.setting_guid;
    temp.company_no = punchCardAddressSetting.company_no;
    temp.address_guid = punchCardAddressSetting.address_guid;
    temp.setting_id = punchCardAddressSetting.setting_id;
    temp.name = punchCardAddressSetting.name;
    temp.longitude = punchCardAddressSetting.longitude;
    temp.latitude = punchCardAddressSetting.latitude;
    temp.country = punchCardAddressSetting.country;
    temp.province = punchCardAddressSetting.province;
    temp.city = punchCardAddressSetting.city;
    temp.subdistrict = punchCardAddressSetting.subdistrict;
    temp.address = punchCardAddressSetting.address;
    temp.create_by = punchCardAddressSetting.create_by;
    temp.user_guid = punchCardAddressSetting.user_guid;
    temp.create_on_utc = punchCardAddressSetting.create_on_utc;
    temp.update_by = punchCardAddressSetting.update_by;
    temp.update_on_utc = punchCardAddressSetting.update_on_utc;
    return temp;
}

@end
