//
//  RepCalendarEditController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepCalendarEditController.h"
#import "SelectDateController.h"
#import "Employee.h"
#import "CalendarSelectAlertTime.h"
#import "RepCalendarView.h"
#import "MuliteSelectController.h"
#import "CalendarRepSelect.h"
#import "Calendar.h"
#import "UserManager.h"
#import "UserHttp.h"

@interface RepCalendarEditController ()<MuliteSelectDelegate,CalendarRepSelectDelegate,RepCalendarViewDelegate>{
    RepCalendarView *_repCalendarView;
    Calendar *_calendar;
    UserManager *_userManager;
}

@end

@implementation RepCalendarEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日程编辑";
    _userManager = [UserManager manager];
    _repCalendarView = [[RepCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    _repCalendarView.data = _calendar;
    _repCalendarView.delegate = self;
    [self.view addSubview:_repCalendarView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)rightClicked:(UIBarButtonItem*)item {
    //修改日程
    [self.navigationController.view showLoadingTips:@"请稍等..."];
    [UserHttp updateUserCalendar:_calendar handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        [self.navigationController.view showSuccessTips:@"修改成功"];
        if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarEdit:)])
            [self.delegate RepCalendarEdit:_calendar];
        [_userManager updateCalendar:_calendar];
        [self.navigationController popViewControllerAnimated:YES];
    }];
//    if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarEdit:)])
//        [self.delegate RepCalendarEdit:_calendar];
//    [_userManager updateCalendar:_calendar];
//    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dataDidChange {
    _calendar = [[Calendar alloc] initWithJSONDictionary:[self.data JSONDictionary]];
}
#pragma mark --
#pragma mark -- RepCalendarViewDelegate
//例行开始时间
- (void)RepCalendarViewBegin {
    SelectDateController *select = [SelectDateController new];
    select.datePickerMode = UIDatePickerModeTime;
    select.selectDateBlock = ^(NSDate *date) {
        _calendar.begindate_utc = [date timeIntervalSince1970] * 1000;
        _repCalendarView.data = _calendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
//例行结束时间
- (void)RepCalendarViewEnd {
    SelectDateController *select = [SelectDateController new];
    select.datePickerMode = UIDatePickerModeTime;
    select.selectDateBlock = ^(NSDate *date) {
        _calendar.enddate_utc = [date timeIntervalSince1970] * 1000;
        _repCalendarView.data = _calendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
//重复性选择
- (void)RepCalendarSelectRep {
    CalendarRepSelect *select = [CalendarRepSelect new];
    select.delegate = self;
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
-(void)calendarRepSelect:(EKRecurrenceRule *)eKRecurrenceRule {
    _calendar.repeat_type = eKRecurrenceRule.frequency + 1;
    _calendar.rrule = [eKRecurrenceRule rRuleString];
    _repCalendarView.data = _calendar;
}
//例行重复时间开始
- (void)RepCalendarViewRepBegin {
    SelectDateController *select = [SelectDateController new];
    select.datePickerMode = UIDatePickerModeDate;
    select.selectDateBlock = ^(NSDate *date) {
        _calendar.r_begin_date_utc = [date timeIntervalSince1970] * 1000;
        _repCalendarView.data = _calendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
//例行重复时间结束
- (void)RepCalendarViewRepEnd {
    SelectDateController *select = [SelectDateController new];
    select.datePickerMode = UIDatePickerModeDate;
    select.selectDateBlock = ^(NSDate *date) {
        _calendar.r_end_date_utc = [date timeIntervalSince1970] * 1000;
        _repCalendarView.data = _calendar;
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
        _calendar.alert_minutes_before = date;
        _calendar.is_alert = YES;
        _repCalendarView.data = _calendar;
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
        _calendar.alert_minutes_after = date;
        _calendar.is_alert = YES;
        _repCalendarView.data = _calendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
//一般事务事后分享
- (void)ComCanendarShare {
    MuliteSelectController *mulite = [MuliteSelectController new];
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    mulite.outEmployees = [@[employee] mutableCopy];
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
    _calendar.members = [guidArr componentsJoinedByString:@","];
    _calendar.member_names = [nameArr componentsJoinedByString:@","];
    _repCalendarView.data = _calendar;
}

@end

