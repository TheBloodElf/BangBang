//
//  ComCalendarEditController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//一般事务编辑
@class Calendar;
@protocol ComCalendarEditDelegate <NSObject>

- (void)ComCalendarEdit:(Calendar*)Calendar;

@end

@interface ComCalendarEditController : UIViewController

@property (nonatomic, weak) id<ComCalendarEditDelegate> delegate;

@end
