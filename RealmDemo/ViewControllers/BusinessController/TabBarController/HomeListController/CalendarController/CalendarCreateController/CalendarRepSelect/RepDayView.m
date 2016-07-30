//
//  RepDayView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepDayView.h"

@interface RepDayView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *topBtn;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;
@property (weak, nonatomic) IBOutlet UITextField *dayField;

@end

@implementation RepDayView
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
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
- (IBAction)topClicked:(id)sender {
    self.topBtn.selected = YES;
    self.bottomBtn.selected = NO;
}

- (IBAction)bottomClicked:(id)sender {
    self.topBtn.selected = NO;
    self.bottomBtn.selected = YES;
}

@end
