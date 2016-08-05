//
//  CalendarCreateController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CalendarCreateController.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "ComCalendarView.h"
#import "RepCalendarView.h"
#import "SelectDateController.h"
#import "CalendarSelectAlertTime.h"
#import "MuliteSelectController.h"
#import "CalendarRepSelect.h"

@interface CalendarCreateController ()<UIScrollViewDelegate,ComCalendarViewDelegate,RepCalendarViewDelegate,MuliteSelectDelegate,CalendarRepSelectDelegate> {
    UISegmentedControl *_segmentedControl;
    UIScrollView *_bottomScrollView;//下面的滚动视图
    Calendar *_currCalendar;//新建的事务
    UserManager *_userManager;//用户管理器
    ComCalendarView *_comCalendarView;//一般事务
    RepCalendarView *_repCalendarView;//例行事务
}

@end

@implementation CalendarCreateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新建事务";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    //初始化日程模型
    _currCalendar = [Calendar new];
    _currCalendar.company_no = _userManager.user.currCompany.company_no;
    _currCalendar.begindate_utc = [[NSDate date] timeIntervalSince1970] * 1000;
    _currCalendar.enddate_utc = _currCalendar.begindate_utc;
    _currCalendar.repeat_type = 0;//先不重复
    _currCalendar.alert_minutes_after = 10;
    _currCalendar.alert_minutes_before = 10;
    _currCalendar.is_alert = NO;
    _currCalendar.user_guid = _userManager.user.user_guid;
    _currCalendar.created_by = _userManager.user.user_guid;
    _currCalendar.emergency_status = 0;
    _currCalendar.r_begin_date_utc = _currCalendar.r_end_date_utc = _currCalendar.begindate_utc;
    _currCalendar.app_guid = @"";
    _currCalendar.rrule = @"";
    _currCalendar.descriptionStr = @"";
    _currCalendar.address = @"";
    _currCalendar.target_id = @"";
    _currCalendar.rdate = @"";
    _currCalendar.members = @"";
    _currCalendar.member_names= @"";
    //创建分段控件
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"一般事务",@"例行事务"]];
    _segmentedControl.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 36);
    _segmentedControl.tintColor = [UIColor calendarColor];
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentedControl];
    //创建表格视图
    _bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 36, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 36)];
    _bottomScrollView.showsVerticalScrollIndicator = _bottomScrollView.showsHorizontalScrollIndicator = NO;
    _bottomScrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH * 2, MAIN_SCREEN_HEIGHT - 100);
    _bottomScrollView.pagingEnabled = YES;
    _bottomScrollView.delegate = self;
    _bottomScrollView.showsVerticalScrollIndicator = _bottomScrollView.showsHorizontalScrollIndicator = NO;
    _comCalendarView = [[ComCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, _bottomScrollView.frame.size.height)];
    _comCalendarView.data = _currCalendar;
    _comCalendarView.delegate = self;
    [_bottomScrollView addSubview:_comCalendarView];
    _repCalendarView = [[RepCalendarView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, _bottomScrollView.frame.size.height)];
    _repCalendarView.data = _currCalendar;
    _repCalendarView.delegate = self;
    [_bottomScrollView addSubview:_repCalendarView];
    [self.view addSubview:_bottomScrollView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)segmentClicked:(UISegmentedControl*)seControl {
    [_bottomScrollView setContentOffset:CGPointMake(seControl.selectedSegmentIndex * _bottomScrollView.frame.size.width, 0) animated:YES];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    //检查有没有内容没有填写
    if([NSString isBlank:_currCalendar.event_name]) {
        [self.navigationController.view showMessageTips:@"请填写事务名称"];
        return;
    }
    //创建日程
    [UserHttp createUserCalendar:_currCalendar handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        Calendar *calendar = [[Calendar alloc] initWithJSONDictionary:data];
        calendar.descriptionStr = data[@"description"];
        [_userManager addCalendar:calendar];
        [self.navigationController showSuccessTips:@"添加成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
//    _currCalendar.id = [[NSDate date] timeIntervalSince1970];
//    [_userManager addCalendar:_currCalendar];
//    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --
#pragma mark -- RepCalendarViewDelegate
//例行开始时间
- (void)RepCalendarViewBegin {
    SelectDateController *select = [SelectDateController new];
    select.datePickerMode = UIDatePickerModeTime;
    select.selectDateBlock = ^(NSDate *date) {
        _currCalendar.begindate_utc = [date timeIntervalSince1970] * 1000;
        _repCalendarView.data = _currCalendar;
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
        _currCalendar.enddate_utc = [date timeIntervalSince1970] * 1000;
        _repCalendarView.data = _currCalendar;
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
#pragma mark -- 
#pragma mark -- CalendarRepSelectDelegate
-(void)calendarRepSelect:(EKRecurrenceRule *)eKRecurrenceRule {
    _currCalendar.repeat_type = eKRecurrenceRule.frequency + 1;
    _currCalendar.rrule = [eKRecurrenceRule rRuleString];
    _repCalendarView.data = _currCalendar;
}
//例行重复时间开始
- (void)RepCalendarViewRepBegin {
    SelectDateController *select = [SelectDateController new];
    select.datePickerMode = UIDatePickerModeDate;
    select.selectDateBlock = ^(NSDate *date) {
        _currCalendar.r_begin_date_utc = [date timeIntervalSince1970] * 1000;
        _repCalendarView.data = _currCalendar;
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
        _currCalendar.r_end_date_utc = [date timeIntervalSince1970] * 1000;
        _repCalendarView.data = _currCalendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
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
        _repCalendarView.data = _currCalendar;
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
        _repCalendarView.data = _currCalendar;
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
        [guidArr addObject:_userManager.user.user_guid];
        [nameArr addObject:_userManager.user.real_name];
    }
    _currCalendar.members = [guidArr componentsJoinedByString:@","];
    _currCalendar.member_names = [nameArr componentsJoinedByString:@","];
    _repCalendarView.data = _currCalendar;
    _comCalendarView.data = _currCalendar;
}
#pragma mark -- 
#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _segmentedControl.selectedSegmentIndex = (scrollView.contentOffset.x + scrollView.frame.size.width / 2) / scrollView.frame.size.width;
    if(_segmentedControl.selectedSegmentIndex == 0)
        _comCalendarView.data = _currCalendar;
    else
        _repCalendarView.data = _currCalendar;
}
@end
