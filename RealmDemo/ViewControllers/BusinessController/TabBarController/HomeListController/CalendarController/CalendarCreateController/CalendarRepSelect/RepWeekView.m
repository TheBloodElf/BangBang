//
//  RepWeekView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepWeekView.h"

@interface RepWeekView ()

@property (weak, nonatomic) IBOutlet UITextField *weekTextField;

@end

@implementation RepWeekView

- (IBAction)weekBtnClicked:(UIButton*)btn {
    btn.selected = !btn.selected;
}
- (EKRecurrenceRule*)eKRecurrenceRule {
    NSInteger interval = [self.weekTextField.text integerValue] ?: 1;
    NSMutableArray *days = [@[] mutableCopy];
    ////////////
    UIButton *Sunday = [self viewWithTag:1000 + 1];
    if(Sunday.selected == YES) {
        [days addObject:[EKRecurrenceDayOfWeek dayOfWeek:EKWeekdaySunday]];
    }
    UIButton *Monday = [self viewWithTag:1000 + 2];
    if(Monday.selected == YES) {
        [days addObject:[EKRecurrenceDayOfWeek dayOfWeek:EKWeekdayMonday]];
    }
    UIButton *Tuesday = [self viewWithTag:1000 + 3];
    if(Tuesday.selected == YES) {
        [days addObject:[EKRecurrenceDayOfWeek dayOfWeek:EKWeekdayTuesday]];
    }
    UIButton *Wednesday = [self viewWithTag:1000 + 4];
    if(Wednesday.selected == YES) {
        [days addObject:[EKRecurrenceDayOfWeek dayOfWeek:EKWeekdayWednesday]];
    }
    UIButton *Thursday = [self viewWithTag:1000 + 5];
    if(Thursday.selected == YES) {
        [days addObject:[EKRecurrenceDayOfWeek dayOfWeek:EKWeekdayThursday]];
    }
    UIButton *Friday = [self viewWithTag:1000 + 6];
    if(Friday.selected == YES) {
        [days addObject:[EKRecurrenceDayOfWeek dayOfWeek:EKWeekdayFriday]];
    }
    UIButton *Saturday = [self viewWithTag:1000 + 7];
    if(Saturday.selected == YES) {
        [days addObject:[EKRecurrenceDayOfWeek dayOfWeek:EKWeekdaySaturday]];
    }
    ///////////
    EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:interval daysOfTheWeek:days daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:nil];
    return rule;
}
- (void)resetUI {
    [self endEditing:YES];
    self.weekTextField.text = @"1";
    for (int i = 1;i <= 7;i ++) {
        UIButton *btn = [self viewWithTag:1000 + i];
        btn.selected = NO;
    }
    UIButton *btn = [self viewWithTag:1000 + 1];
    btn.selected = YES;
}

@end
