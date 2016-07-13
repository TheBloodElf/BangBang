//
//  User.h
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Realm/Realm.h>

@interface User : RLMObject

/** 用户唯一编号 */
@property (nonatomic, strong) NSString  * user_guid;
/** 用户唯一编号 */
@property (nonatomic, strong) NSString  * user_name;
/** 用户编号 */
@property (nonatomic, strong) NSString  * user_no;
/** email(帐号) */
@property (nonatomic, strong) NSString  * email;
/** 姓名 必填 */
@property (nonatomic, strong) NSString  * real_name;
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
/** 工作圈编号 */
@property (nonatomic, strong) NSString  * company_no;
/** 工作编号 */
@property (nonatomic, strong) NSString  * employee_guid;
/** 工作圈 */
@property (nonatomic, strong) NSString  * company_name;

@end
