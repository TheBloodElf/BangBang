//
//  UserCompanyModel.h
//  BangBang
//
//  Created by Kiwaro on 14-12-16.
//  Copyright (c) 2014年 Kiwaro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompanyModel : NSObject
/** 工作圈编号 */
@property (nonatomic, strong) NSString      * company_no;
/** 工作圈名字 */
@property (nonatomic, strong) NSString      * company_name;
/** 工作圈类型，非必填，默认为6。 1-国有企业 2-私有企业 3-事业单位或社会团体 4-中外合资 5-外商独资 6-其他 */
@property (nonatomic, strong) NSString      * company_type;
/** 工作圈logo */
@property (nonatomic, strong) NSString      * logo;

/** 工作圈管理员 */
@property (nonatomic, strong) NSString      * admin_user_guid;
/** 是否被选中 */
@property (nonatomic, assign) BOOL isSelected;

@end
