//
//  RepCalendarTime.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

//时间
@protocol RepCalendarTimeDelegate <NSObject>

//开始事件被点击
- (void)repCalendarTimeBeginTime;
//结束事件被点击
- (void)repCalendarTimeEndTime;
//全天被点击
- (void)repCalendarTimeAllDay;

@end

@interface RepCalendarTime : UITableViewCell

@property (nonatomic, weak) id<RepCalendarTimeDelegate> delegate;

@end
