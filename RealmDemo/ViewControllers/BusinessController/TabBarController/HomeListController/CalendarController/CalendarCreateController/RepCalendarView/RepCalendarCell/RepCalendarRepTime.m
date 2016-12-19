//
//  RepCalendarRepTime.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepCalendarRepTime.h"
#import "Calendar.h"

@interface RepCalendarRepTime () {
    Calendar *_calendar;
}

@property (weak, nonatomic) IBOutlet UIButton *beginTime;
@property (weak, nonatomic) IBOutlet UIButton *endTime;

@end

@implementation RepCalendarRepTime

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)endTime:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarRepTimeEnd)]) {
        [self.delegate RepCalendarRepTimeEnd];
    }
}
- (IBAction)beginTime:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarRepTimeBgein)]) {
        [self.delegate RepCalendarRepTimeBgein];
    }
}

- (void)dataDidChange {
    _calendar = self.data;
    NSDate *beginTime = [NSDate dateWithTimeIntervalSince1970:_calendar.r_begin_date_utc / 1000];
    NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:_calendar.r_end_date_utc / 1000];
    [self.beginTime setTitle:[NSString stringWithFormat:@"%ld-%ld-%ld",(long)beginTime.year,(long)beginTime.month,(long)beginTime.day] forState:UIControlStateNormal];
    [self.endTime setTitle:[NSString stringWithFormat:@"%ld-%ld-%ld",(long)endTime.year,(long)endTime.month,(long)endTime.day] forState:UIControlStateNormal];
}

@end
