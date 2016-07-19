//
//  ComCalendarTime.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarTime.h"
#import "Calendar.h"

@interface ComCalendarTime () {
    Calendar *_calendar;
}
@property (weak, nonatomic) IBOutlet UIButton *beginTime;
@property (weak, nonatomic) IBOutlet UIButton *endTime;
@property (weak, nonatomic) IBOutlet UIButton *allDayBtn;

@end

@implementation ComCalendarTime

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)beginTime:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(comCalendarTimeBeginTime)]) {
        [self.delegate comCalendarTimeBeginTime];
    }
}
- (IBAction)endTime:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(comCalendarTimeEndTime)]) {
        [self.delegate comCalendarTimeEndTime];
    }
}
- (IBAction)allDayClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(comCalendarTimeAllDay)]) {
        [self.delegate comCalendarTimeAllDay];
    }
}

- (void)dataDidChange {
    _calendar = self.data;
    NSDate *beginTime = [NSDate dateWithTimeIntervalSince1970:_calendar.begindate_utc / 1000];
    NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:_calendar.enddate_utc / 1000];
    if(_calendar.is_allday == YES) {
        //全天事件，只显示年月日
        [self.beginTime setTitle:[NSString stringWithFormat:@"%d-%d-%d",beginTime.year,beginTime.month,beginTime.day] forState:UIControlStateNormal];
        [self.endTime setTitle:[NSString stringWithFormat:@"%d-%d-%d",endTime.year,endTime.month,endTime.day] forState:UIControlStateNormal];
        [self.allDayBtn setBackgroundColor:[UIColor blackColor]];
        [self.allDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        //非全天事件，显示年月日 时分
        [self.beginTime setTitle:[NSString stringWithFormat:@"%d-%d-%d\n%d:%d",beginTime.year,beginTime.month,beginTime.day,beginTime.hour,beginTime.minute] forState:UIControlStateNormal];
        [self.endTime setTitle:[NSString stringWithFormat:@"%d-%d-%d\n%d:%d",endTime.year,endTime.month,endTime.day,endTime.hour,endTime.minute] forState:UIControlStateNormal];
        [self.allDayBtn setBackgroundColor:[UIColor whiteColor]];
        [self.allDayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}
@end
