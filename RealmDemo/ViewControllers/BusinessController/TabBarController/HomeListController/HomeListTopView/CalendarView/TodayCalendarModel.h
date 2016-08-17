//
//  TodayCalendarModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//today扩展存放的数据模型
@interface TodayCalendarModel : NSObject

/** 事务编号 */
@property (nonatomic, assign) int64_t id;
/** 事务名称 */
@property (nonatomic, strong) NSString    *event_name;
/** 事务描述 */
@property (nonatomic, strong) NSString   *descriptionStr;
/** 开始时间 毫秒 */
@property (nonatomic, assign) int64_t    begindate_utc;
/** 结束时间 毫秒 */
@property (nonatomic, assign) int64_t    enddate_utc;

@end
