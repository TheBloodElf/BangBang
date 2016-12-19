//
//  CalendarComDetailView.h
//  RealmDemo
//
//  Created by Mac on 2016/12/7.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//一般事务详情 不能操作

@protocol ComCalendarViewDelegate <NSObject>

- (void)ComCalendarViewBegin;//开始时间
- (void)ComCalendarViewEnd;//结束时间
- (void)ComCanendarAlertBefore;//事前提醒
- (void)ComCanendarAlertAfter;//事后提醒
- (void)ComCanendarShare;//分享

@end
@interface CalendarComDetailView : UIView

@property (nonatomic, weak) id<ComCalendarViewDelegate> delegate;

@end
