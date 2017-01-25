//
//  Employee.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/14.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

//员工
@interface Employee : RLMObject
/** id  */
@property (nonatomic, assign) int id;
/** 员工guid */
@property (nonatomic, strong) NSString  * employee_guid;
/** 姓名 必填 */
@property (nonatomic, strong) NSString  * real_name;
/** 性别：0-保密 1-男 2-女 */
@property (nonatomic, assign) int sex;
/** 用户唯一编号 */
@property (nonatomic, strong) NSString  * user_guid;
/** 用户编号 */
@property (nonatomic, assign) int user_no;
/** 用户唯一编号 */
@property (nonatomic, strong) NSString  * user_name;
/** 姓名 必填 */
@property (nonatomic, strong) NSString  * user_real_name;
/** email(帐号) */
@property (nonatomic, strong) NSString  * email;
/** phone */
@property (nonatomic, strong) NSString  * phone;
/** 手机号 */
@property (nonatomic, strong) NSString  * mobile;
/** qq */
@property (nonatomic, strong) NSString  * QQ;
/** weixin */
@property (nonatomic, strong) NSString  * weixin;
/** 圈子编号 */
@property (nonatomic, assign) int company_no;
/** 创建时间 */
@property (nonatomic, assign) int64_t created;
/** 更新时间 */
@property (nonatomic, assign) int64_t updated;
/** 头像 */
@property (nonatomic, strong) NSString  * avatar;
/** 心情动态 */
@property (nonatomic, strong) NSString  * mood;
/** 加入理由 */
@property (nonatomic, strong) NSString  * join_reason;
/** 离职理由 */
@property (nonatomic, strong) NSString  * leave_reason;
/** status 员工状态:0-待审核(申请加入)，1-在职，2-已离职，3-拒绝加入 4-申请离职中(默认在职） */
//本地：-1（所有）, 5（1/4）
@property (nonatomic, assign) int status;
/** 是不是管理员 */
@property (nonatomic, assign) int is_admin;
/** 所在部门 */
@property (nonatomic, strong) NSString *departments;

@end
