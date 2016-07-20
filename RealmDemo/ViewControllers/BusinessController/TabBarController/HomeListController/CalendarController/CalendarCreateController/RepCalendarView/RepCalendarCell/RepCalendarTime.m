//
//  RepCalendarTime.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepCalendarTime.h"
#import "Calendar.h"

@interface RepCalendarTime () {
    Calendar *_calendar;
}

@property (weak, nonatomic) IBOutlet UIButton *beginTime;
@property (weak, nonatomic) IBOutlet UIButton *endTime;
@property (weak, nonatomic) IBOutlet UIButton *allDayBtn;

@end

@implementation RepCalendarTime

- (void)awakeFromNib {
    [super awakeFromNib];
    
}
- (IBAction)beginTime:(id)sender {
    if(_calendar.is_allday == YES)
        return;
    if(self.delegate && [self.delegate respondsToSelector:@selector(repCalendarTimeBeginTime)]) {
        [self.delegate repCalendarTimeBeginTime];
    }
}
- (IBAction)endTime:(id)sender {
    if(_calendar.is_allday == YES)
        return;
    if(self.delegate && [self.delegate respondsToSelector:@selector(repCalendarTimeEndTime)]) {
        [self.delegate repCalendarTimeEndTime];
    }
}
- (IBAction)allDayClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(repCalendarTimeAllDay)]) {
        [self.delegate repCalendarTimeAllDay];
    }
}

- (void)dataDidChange {
    _calendar = self.data;
    NSDate *beginTime = [NSDate dateWithTimeIntervalSince1970:_calendar.begindate_utc / 1000];
    NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:_calendar.enddate_utc / 1000];
    if(_calendar.is_allday == YES) {
        //全天事件，只显示年月日
        [self.beginTime setTitle:@"00:00" forState:UIControlStateNormal];
        [self.endTime setTitle:@"23:59" forState:UIControlStateNormal];
        [self.allDayBtn setBackgroundColor:[UIColor blackColor]];
        [self.allDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [self.beginTime setTitle:[NSString stringWithFormat:@"%d:%d",beginTime.hour,beginTime.minute] forState:UIControlStateNormal];
        [self.endTime setTitle:[NSString stringWithFormat:@"%d:%d",endTime.hour,endTime.minute] forState:UIControlStateNormal];
        [self.allDayBtn setBackgroundColor:[UIColor whiteColor]];
        [self.allDayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}
@end
