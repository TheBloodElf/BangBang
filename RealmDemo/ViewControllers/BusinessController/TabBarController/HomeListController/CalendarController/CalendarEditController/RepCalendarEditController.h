//
//  RepCalendarEditController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//例行事务编辑
@class Calendar;
@protocol RepCalendarEditDelegate <NSObject>

- (void)RepCalendarEdit:(Calendar*)Calendar;

@end

@interface RepCalendarEditController : UIViewController

@property (nonatomic, weak) id<RepCalendarEditDelegate> delegate;

@end
