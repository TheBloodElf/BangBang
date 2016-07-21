//
//  RepDayView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepDayView.h"

@interface RepDayView ()

@property (weak, nonatomic) IBOutlet UIButton *topBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UITextField *dayField;

@end

@implementation RepDayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.dayField.returnKeyType = UIReturnKeyDone;
        self.dayField.keyboardType = UIKeyboardTypeNamePhonePad;
    }
    return self;
}
- (EKRecurrenceRule*)eKRecurrenceRule {
    NSInteger interval = 1;
    NSArray *days = @[];
    if(self.topBtn.selected == YES) {
        interval = [self.dayField.text integerValue] ?: 1;
        days = nil;
    } else {
        interval = 1;
        days = @[[EKRecurrenceDayOfWeek dayOfWeek:EKMonday],[EKRecurrenceDayOfWeek dayOfWeek:EKTuesday],[EKRecurrenceDayOfWeek dayOfWeek:EKWednesday],[EKRecurrenceDayOfWeek dayOfWeek:EKThursday],[EKRecurrenceDayOfWeek dayOfWeek:EKFriday]];
    }
    EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:interval daysOfTheWeek:days daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:nil];
    return rule;
}
- (void)resetUI {
    [self endEditing:YES];
    self.topBtn.selected = YES;
    self.bottomBtn.selected = NO;
    self.dayField.text = @"1";
}
- (IBAction)topClicked:(id)sender {
    self.topBtn.selected = YES;
    self.bottomBtn.selected = NO;
}

- (IBAction)bottomClicked:(id)sender {
    self.topBtn.selected = NO;
    self.bottomBtn.selected = YES;
}

@end
