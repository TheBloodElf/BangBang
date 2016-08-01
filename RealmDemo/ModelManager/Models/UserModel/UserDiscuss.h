//
//  UserDiscuss.h
//  RealmDemo
//
//  Created by Mac on 16/7/18.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

/**
 *  用户讨论组
 */
@interface UserDiscuss : RLMObject
/**
 *  讨论组主键
 */
@property(nonatomic,assign)int id;
/**
 *  用户编号
 */
@property(nonatomic,assign)int user_no;
/**
 *  用户唯一标识
 */
@property(nonatomic,strong)NSString *user_guid;
/**
 *  讨论组编号
 */
@property(nonatomic,strong)NSString *discuss_id;
/**
 *  讨论组标题
 */
@property(nonatomic,strong)NSString *discuss_title;
/**
 *  创建日期
 */
@property(nonatomic,assign)int64_t createdon_utc;

@end
