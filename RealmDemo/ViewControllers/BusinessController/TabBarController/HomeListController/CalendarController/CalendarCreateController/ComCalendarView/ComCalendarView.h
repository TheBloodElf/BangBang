//
//  ComCalendarView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//一般事务

@protocol ComCalendarViewDelegate <NSObject>

- (void)ComCalendarViewBegin;
- (void)ComCalendarViewEnd;

@end

@interface ComCalendarView : UIView

@property (nonatomic, weak) id<ComCalendarViewDelegate> delegate;

@end
