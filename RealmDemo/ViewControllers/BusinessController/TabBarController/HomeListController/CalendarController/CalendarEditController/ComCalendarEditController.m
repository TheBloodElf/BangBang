//
//  ComCalendarEditController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarEditController.h"
#import "ComCalendarView.h"
#import "SelectDateController.h"
#import "Calendar.h"
#import "CalendarSelectAlertTime.h"
#import "MuliteSelectController.h"
#import "UserManager.h"

@interface ComCalendarEditController ()<ComCalendarViewDelegate,MuliteSelectDelegate> {
    Calendar *_currCalendar;
    ComCalendarView *_comCalendarView;
}

@end

@implementation ComCalendarEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    _comCalendarView = [[ComCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 50)];
    _comCalendarView.data = _currCalendar;
    _comCalendarView.delegate = self;
    [self.view addSubview:_comCalendarView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)rightClicked:(UIBarButtonItem*)item {
    if(self.delegate && [self.delegate respondsToSelector:@selector(ComCalendarEdit:)])
        [self.delegate ComCalendarEdit:_currCalendar];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dataDidChange {
    _currCalendar = [Calendar copyFromCalendar:self.data];
}
#pragma mark --
#pragma mark -- ComCalendarViewDelegate
//一般事务开始时间被点击
- (void)ComCalendarViewBegin {
    SelectDateController *select = [SelectDateController new];
    select.datePickerMode = _currCalendar.is_allday ? UIDatePickerModeDate : UIDatePickerModeDateAndTime;
    select.selectDateBlock = ^(NSDate *date) {
        _currCalendar.begindate_utc = [date timeIntervalSince1970] * 1000;
        _comCalendarView.data = _currCalendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
//一般事务结束时间被点击
- (void)ComCalendarViewEnd {
    SelectDateController *select = [SelectDateController new];
    select.datePickerMode = _currCalendar.is_allday ? UIDatePickerModeDate : UIDatePickerModeDateAndTime;
    select.selectDateBlock = ^(NSDate *date) {
        _currCalendar.enddate_utc = [date timeIntervalSince1970] * 1000;
        _comCalendarView.data = _currCalendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
//一般事务事前提醒
- (void)ComCanendarAlertBefore {
    CalendarSelectAlertTime *select = [CalendarSelectAlertTime new];
    select.calendarSelectTime = ^(int date) {
        _currCalendar.alert_minutes_before = date;
        _currCalendar.is_alert = YES;
        _comCalendarView.data = _currCalendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
//一般事务事后提醒
- (void)ComCanendarAlertAfter {
    CalendarSelectAlertTime *select = [CalendarSelectAlertTime new];
    select.calendarSelectTime = ^(int date) {
        _currCalendar.alert_minutes_after = date;
        _currCalendar.is_alert = YES;
        _comCalendarView.data = _currCalendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
//一般事务事后分享
- (void)ComCanendarShare {
    MuliteSelectController *mulite = [MuliteSelectController new];
    mulite.delegate = self;
    [self.navigationController pushViewController:mulite animated:YES];
}
#pragma mark --
#pragma mark -- MuliteSelectDelegate
//多选回调
- (void)muliteSelect:(NSMutableArray<Employee*>*)employeeArr {
    NSMutableArray *guidArr = [@[] mutableCopy];
    NSMutableArray *nameArr = [@[] mutableCopy];
    for (Employee *employee in employeeArr) {
        [guidArr addObject:employee.user_guid];
        [nameArr addObject:employee.real_name];
    }
    //如果有数据，就要加上自己（应付服务器）
    if(employeeArr.count) {
        [guidArr addObject:[UserManager manager].user.user_guid];
        [nameArr addObject:[UserManager manager].user.real_name];
    }
    _currCalendar.members = [guidArr componentsJoinedByString:@","];
    _currCalendar.member_names = [nameArr componentsJoinedByString:@","];
    _comCalendarView.data = _currCalendar;
}
@end
