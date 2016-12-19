//
//  ComCalendarEditController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarEditController.h"
#import "CalendarComEditView.h"
#import "SelectDateController.h"
#import "Calendar.h"
#import "CalendarSelectAlertTime.h"
#import "MuliteSelectController.h"
#import "UserManager.h"
#import "UserHttp.h"

@interface ComCalendarEditController ()<ComCalendarViewDelegate,MuliteSelectDelegate> {
    Calendar *_currCalendar;
    CalendarComEditView *_comCalendarView;
    UserManager *_userManager;
}

@end

@implementation ComCalendarEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日程编辑";
    _userManager = [UserManager manager];
    _comCalendarView = [[CalendarComEditView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    _comCalendarView.data = _currCalendar;
    _comCalendarView.delegate = self;
    [self.view addSubview:_comCalendarView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightClicked:)];
    //确定按钮是否能够被点击
    RACSignal *nameSignal = RACObserve(_currCalendar, event_name);
    RAC(self.navigationItem.rightBarButtonItem,enabled) = [nameSignal map:^(NSString* name) {
        if([NSString isBlank:name])
            return @(NO);
        return @(YES);
    }];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    [self.view endEditing:YES];
    if([NSString isBlank:_currCalendar.event_name]) {
        [self.navigationController.view showMessageTips:@"请填写事务名称"];
        return;
    }
    if(_currCalendar.enddate_utc < _currCalendar.begindate_utc) {
        [self.navigationController.view showMessageTips:@"开始时间不能晚于结束时间"];
        return;
    }
    //修改日程
    [UserHttp updateUserCalendar:_currCalendar handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            if(error.statsCode == -1009) {//断网也可以操作，只是离线的而已
                _currCalendar.needSync = YES;
                _currCalendar.updated_by = _userManager.user.user_guid;
                _currCalendar.updatedon_utc = [NSDate date].timeIntervalSince1970 * 1000;
                if(self.delegate && [self.delegate respondsToSelector:@selector(ComCalendarEdit:)])
                    [self.delegate ComCalendarEdit:_currCalendar];
                [_userManager updateCalendar:_currCalendar];
                [self.navigationController popViewControllerAnimated:YES];
                return ;
            }
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(ComCalendarEdit:)])
            [self.delegate ComCalendarEdit:_currCalendar];
        [_userManager updateCalendar:_currCalendar];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
- (void)dataDidChange {
    _currCalendar = [self.data deepCopy];
}
#pragma mark --
#pragma mark -- ComCalendarViewDelegate
//一般事务开始时间被点击
- (void)ComCalendarViewBegin {
    SelectDateController *select = [SelectDateController new];
    select.needShowDate = [NSDate dateWithTimeIntervalSince1970:_currCalendar.begindate_utc / 1000];
    select.datePickerMode = _currCalendar.is_allday ? UIDatePickerModeDate : UIDatePickerModeDateAndTime;
    select.selectDateBlock = ^(NSDate *date) {
        _currCalendar.begindate_utc = [date timeIntervalSince1970] * 1000;
        //结束时间自动加30分钟
        _currCalendar.enddate_utc = [date timeIntervalSince1970] * 1000 + 1000 * 30 * 60;
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
    select.needShowDate = [NSDate dateWithTimeIntervalSince1970:_currCalendar.enddate_utc / 1000];
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
    select.userSelectTime = _currCalendar.alert_minutes_before;
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
    select.userSelectTime = _currCalendar.alert_minutes_after;
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
    //添加加入的所有圈子的员工
    NSMutableDictionary<NSString*,Employee*> *allCompanysEmployees = [@{_userManager.user.user_guid:[Employee new]} mutableCopy];
    //便利所有圈子
    for (Company *company in [_userManager getCompanyArr]) {
        //获取自己在该圈子中的员工
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
        //只显示自己状态为4或者1的
        if(employee.status == 1 || employee.status == 4) {
            //遍历该圈子的所有员工
            for (Employee *tempEmployee in [_userManager getEmployeeWithCompanyNo:company.company_no status:5]) {
                [allCompanysEmployees setObject:tempEmployee forKey:tempEmployee.user_guid];
            }
        }
    }
    //去掉自己的
    [allCompanysEmployees removeObjectForKey:_userManager.user.user_guid];
    mulite.discussMember = [allCompanysEmployees.allValues mutableCopy];
    //设置已经选中的人
    NSArray *guidArr = [_currCalendar.members componentsSeparatedByString:@","];
    NSMutableArray *employeeArr = [@[] mutableCopy];
    for (NSString *userGuid in guidArr) {
        Employee *employee = [Employee new];
        employee.user_guid = userGuid;
        [employeeArr addObject:employee];
    }
    mulite.selectedEmployees = employeeArr;
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
