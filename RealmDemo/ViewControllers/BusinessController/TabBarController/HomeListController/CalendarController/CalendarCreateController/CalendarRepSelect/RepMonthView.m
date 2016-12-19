//
//  RepMonthView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepMonthView.h"

@interface RepMonthView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *monthTextField;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;


@end

@implementation RepMonthView

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}
//设置默认显示的规则
- (void)setEKRecurrenceRule:(EKRecurrenceRule*)eKRecurrenceRule {
    self.monthTextField.text = @(eKRecurrenceRule.interval).stringValue;
    self.dayTextField.text = eKRecurrenceRule.daysOfTheMonth[0].stringValue;
}
- (EKRecurrenceRule*)eKRecurrenceRule {
    NSInteger interval = self.monthTextField.text.integerValue ?: 1;
    NSArray *days = @[@(self.dayTextField.text.integerValue ?: 1)];
    EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:interval daysOfTheWeek:nil daysOfTheMonth:days monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:nil];
    return rule;
}

@end
