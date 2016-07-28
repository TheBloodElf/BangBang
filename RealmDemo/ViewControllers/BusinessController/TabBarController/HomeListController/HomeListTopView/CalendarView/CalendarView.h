//
//  CalendarView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarViewDeleagate <NSObject>

//今天完成日程被点击
- (void)todayFinishCalendar;
//本周完成日程被点击
- (void)weekFinishCalendar;

@end

@interface CalendarView : UIView

@property (nonatomic, weak) id<CalendarViewDeleagate> delegate;

- (void)setupUI;

@end
