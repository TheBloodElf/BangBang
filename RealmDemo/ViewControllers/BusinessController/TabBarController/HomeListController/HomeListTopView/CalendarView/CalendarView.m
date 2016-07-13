//
//  CalendarView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CalendarView.h"

@implementation CalendarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        //这里先创建两个按钮玩玩，具体的后面来做
        UIButton *todayFinish = [UIButton buttonWithType:UIButtonTypeSystem];
        todayFinish.frame = CGRectMake(0, 0, frame.size.width / 2, frame.size.height);
        [todayFinish setTitle:@"今日完成" forState:UIControlStateNormal];
        [todayFinish addTarget:self action:@selector(todayFinishClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:todayFinish];
        UIButton *weekFinish = [UIButton buttonWithType:UIButtonTypeSystem];
        weekFinish.frame = CGRectMake(frame.size.width / 2, 0, frame.size.width / 2, frame.size.height);
        [weekFinish setTitle:@"本周完成" forState:UIControlStateNormal];
        [weekFinish addTarget:self action:@selector(weekFinishClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:weekFinish];
    }
    return self;
}
- (void)todayFinishClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(todayFinishCalendar)]) {
        [self.delegate todayFinishCalendar];
    }
}
- (void)weekFinishClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(weekFinishCalendar)]) {
        [self.delegate weekFinishCalendar];
    }
}
@end
