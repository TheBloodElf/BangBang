//
//  UserInfo.h
//  RealmDemo
//
//  Created by Mac on 16/7/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//这个是和today扩展统一的模型 目前只需要这些属性
@interface UserInfo : NSObject

/** 用户唯一编号 */
@property (nonatomic, strong) NSString  * user_guid;

@end
