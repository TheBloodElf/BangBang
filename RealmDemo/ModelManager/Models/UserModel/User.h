//
//  User.h
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//


#import "Company.h"
//当前用户
@interface User : RLMObject

/** qq */
@property (nonatomic, strong) NSString  * QQ;
/** 头像 */
@property (nonatomic, strong) NSString  * avatar;
/** email(帐号) */
@property (nonatomic, strong) NSString  * email;
/** 手机号 */
@property (nonatomic, strong) NSString  * mobile;
/** 心情动态 */
@property (nonatomic, strong) NSString  * mood;
/** 姓名 必填 */
@property (nonatomic, strong) NSString  * real_name;
/** 性别：0-保密 1-男 2-女 */
@property (nonatomic, assign) int sex;
/** 用户唯一编号 */
@property (nonatomic, strong) NSString  * user_guid;
/** 用户唯一编号 */
@property (nonatomic, strong) NSString  * user_name;
/** 用户编号 */
@property (nonatomic, assign) int user_no;
/** weixin */
@property (nonatomic, strong) NSString  * weixin;
/** 用户当前所在圈子编号 */
@property (nonatomic, strong) Company *currCompany;
//连接融云的token
@property (nonatomic, copy) NSString *RYToken;
//新消息是否展开（设置界面）
@property (nonatomic, assign) BOOL newMessage;
//推送/聊天信息来了是否播放声音
@property (nonatomic, assign) BOOL canPlayVoice;
//推送来了是否震动
@property (nonatomic, assign) BOOL canPlayShake;
//融云免打扰开始时间
@property (nonatomic, strong) NSDate *ryDisturbBeginTime;
//融云免打扰结束时间
@property (nonatomic, strong) NSDate *ryDisturbEndTime;
//融云免打扰功能
@property (nonatomic, assign) BOOL ryDisturb;

@end

