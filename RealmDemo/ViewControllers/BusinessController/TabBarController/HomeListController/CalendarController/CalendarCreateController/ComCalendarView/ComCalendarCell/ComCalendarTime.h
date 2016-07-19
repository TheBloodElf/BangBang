//
//  ComCalendarTime.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//时间
@protocol ComCalendarTimeDelegate <NSObject>

//开始事件被点击
- (void)comCalendarTimeBeginTime;
//结束事件被点击
- (void)comCalendarTimeEndTime;
//全天被点击
- (void)comCalendarTimeAllDay;

@end

@interface ComCalendarTime : UITableViewCell

@property (nonatomic, weak) id<ComCalendarTimeDelegate> delegate;

@end
