//
//  RepWeekView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepWeekView.h"

@interface RepWeekView ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *weekTextField;

@end

@implementation RepWeekView

- (IBAction)weekBtnClicked:(UIButton*)btn {
    btn.selected = !btn.selected;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}
//设置默认显示的规则
- (void)setEKRecurrenceRule:(EKRecurrenceRule*)eKRecurrenceRule {
    self.weekTextField.text = @(eKRecurrenceRule.interval).stringValue;
    //依次判断哪些被选中
    NSArray *daysOfWeek = eKRecurrenceRule.daysOfTheWeek;
    for (EKRecurrenceDayOfWeek *eKRecurrenceDayOfWeek in daysOfWeek) {
        if(eKRecurrenceDayOfWeek.dayOfTheWeek == EKWeekdaySunday) {
            UIButton *Sunday = [self viewWithTag:1000 + 1];
            Sunday.selected = YES;
        }
        if(eKRecurrenceDayOfWeek.dayOfTheWeek == EKWeekdayMonday) {
            UIButton *Monday = [self viewWithTag:1000 + 2];
            Monday.selected = YES;
        }
        if(eKRecurrenceDayOfWeek.dayOfTheWeek == EKWeekdayTuesday) {
            UIButton *Tuesday = [self viewWithTag:1000 + 3];
            Tuesday.selected = YES;
        }
        if(eKRecurrenceDayOfWeek.dayOfTheWeek == EKWeekdayWednesday) {
            UIButton *Wednesday = [self viewWithTag:1000 + 4];
            Wednesday.selected = YES;
        }
        if(eKRecurrenceDayOfWeek.dayOfTheWeek == EKWeekdayThursday) {
            UIButton *Thursday = [self viewWithTag:1000 + 5];
            Thursday.selected = YES;
        }
        if(eKRecurrenceDayOfWeek.dayOfTheWeek == EKWeekdayFriday) {
            UIButton *Friday = [self viewWithTag:1000 + 6];
            Friday.selected = YES;
        }
        if(eKRecurrenceDayOfWeek.dayOfTheWeek == EKWeekdaySaturday) {
            UIButton *Saturday = [self viewWithTag:1000 + 7];
            Saturday.selected = YES;
        }
    }
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
    //如果一个都没有选中，就默认选中第一个
    if(days.count == 0)
        [days addObject:[EKRecurrenceDayOfWeek dayOfWeek:EKWeekdaySunday]];
    EKRecurrenceRule *rule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:interval daysOfTheWeek:days daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:nil];
    return rule;
}

@end
