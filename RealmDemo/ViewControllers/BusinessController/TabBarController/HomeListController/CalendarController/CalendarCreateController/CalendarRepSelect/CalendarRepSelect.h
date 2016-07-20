//
//  CalendarRepSelect.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//日程创建时 周期设置

@protocol CalendarRepSelectDelegate <NSObject>

- (void)calendarRepSelect:(EKRecurrenceRule*)eKRecurrenceRule;

@end

@interface CalendarRepSelect : UIViewController

@property (nonatomic, weak) id<CalendarRepSelectDelegate> delegate;

@end
