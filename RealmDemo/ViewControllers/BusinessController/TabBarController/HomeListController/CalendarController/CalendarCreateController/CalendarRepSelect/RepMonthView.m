//
//  RepMonthView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepMonthView.h"

@interface RepMonthView ()

@property (weak, nonatomic) IBOutlet UITextField *monthTextField;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;


@end

@implementation RepMonthView

- (EKRecurrenceRule*)eKRecurrenceRule {
    NSInteger interval = self.monthTextField.text.integerValue ?: 1;
    NSArray *days = @[@(self.dayTextField.text.integerValue ?: 1)];
    EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:interval daysOfTheWeek:nil daysOfTheMonth:days monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:nil];
    return rule;
}
- (void)resetUI {
    [self endEditing:YES];
    self.monthTextField.text = @"1";
    self.dayTextField.text = @"1";
}

@end
