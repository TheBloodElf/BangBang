//
//  RepCalendarRep.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepCalendarRep.h"
#import "Calendar.h"

@interface RepCalendarRep (){
    Calendar *_calendar;
}

@property (weak, nonatomic) IBOutlet UIButton *repBtn;

@end

@implementation RepCalendarRep

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)repClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarSelectRep)]) {
        [self.delegate RepCalendarSelectRep];
    }
}
- (void)dataDidChange {
    _calendar = self.data;
    if(_calendar.repeat_type == 0)
        [self.repBtn setTitle:@"不重复" forState:UIControlStateNormal];
    else {
        EKRecurrenceRule *currRule = [[EKRecurrenceRule alloc] initWithString:_calendar.rrule];
        [self.repBtn setTitle:[currRule rRepeatString] forState:UIControlStateNormal];
    }
}
@end
