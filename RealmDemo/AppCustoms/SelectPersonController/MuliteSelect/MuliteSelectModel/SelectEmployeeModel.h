//
//  SelectEmployeeModel.h
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectEmployeeModel : NSObject


/** 用户唯一编号 */
@property (nonatomic, strong) NSString  * user_guid;
/** 用户编号 */
@property (nonatomic, strong) NSString  * user_no;
/** email(帐号) */
@property (nonatomic, strong) NSString  * email;
/** 圈内名*/
@property (nonatomic, strong) NSString  * real_name;
/** 真实姓名*/
@property (nonatomic, strong) NSString  * user_real_name;
/** 索引 */
@property (nonatomic, strong) NSString  * real_nameScreen;
/** 头像 */
@property (nonatomic, strong) NSString  * avatar;
/** 心情动态 */
@property (nonatomic, strong) NSString  * mood;
/** 性别：0-保密 1-男 2-女 */
@property (nonatomic, strong) NSString  * sex;
/** 手机号 */
@property (nonatomic, strong) NSString  * mobile;
/** qq */
@property (nonatomic, strong) NSString  * QQ;
/** weixin */
@property (nonatomic, strong) NSString  * weixin;
/** 员工GUID */
@property (nonatomic, strong) NSString  * employee_guid;
/** 申请原因 */
@property (nonatomic, strong) NSString  * join_reason;
/** 离职原因 */
@property (nonatomic, strong) NSString  * leave_reason;
/** status 员工状态:0-待审核(申请加入)，1-在职，2-已离职，3-已拒绝加入，4-申请离职中(默认在职)，5-包括在职和申请离职中 */
@property (nonatomic, strong) NSString  * status;
/** 圈子的名字 */
@property (nonatomic, strong) NSString  * company_no;
/** created */
@property (nonatomic, strong) NSString  * created;
/** 更新时间 */
@property (nonatomic, strong) NSString  * updated;
/** 帮帮号 */
@property (nonatomic, strong) NSString  * user_name;
/** 是否是圈子管理员 */
@property (nonatomic, strong) NSString  * isManager;

@property (nonatomic, assign) BOOL isSelected;

@end
