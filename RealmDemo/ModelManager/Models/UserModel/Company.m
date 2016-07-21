//
//  Company.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UserManager.h"
#import "Company.h"

@implementation Company

+ (NSString*)primaryKey {
    return @"company_no";
}
- (NSString*)companyTypeStr {
     NSArray *companyTypeArray = @[@"", @"国有企业", @"私有企业", @"事业单位或社会团体", @"中外合资", @"外商独资",@"其他"];
    return companyTypeArray[self.company_type];
}
+ (Company*)copyFromCompany:(Company*)company {
    Company *tempCompany = [Company new];
    tempCompany.admin_user_guid = company.admin_user_guid;
    tempCompany.logo = company.logo;
    tempCompany.company_no = company.company_no;
    tempCompany.company_name = company.company_name;
    tempCompany.company_type = company.company_type;
    return tempCompany;
}
@end
