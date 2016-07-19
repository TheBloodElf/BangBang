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

@interface CalendarCreateController ()<UIScrollViewDelegate,ComCalendarViewDelegate> {
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
    self.automaticallyAdjustsScrollViewInsets = NO;
    //初始化日程模型
    _currCalendar = [Calendar new];
    _currCalendar.company_no = _userManager.user.currCompany.company_no;
    _currCalendar.begindate_utc = [[NSDate date] timeIntervalSince1970] * 1000;
    _currCalendar.enddate_utc = _currCalendar.begindate_utc;
    _currCalendar.repeat_type = 0;
    _currCalendar.user_guid = _userManager.user.user_guid;
    _currCalendar.created_by = _userManager.user.user_guid;
    _currCalendar.emergency_status = 0;
    _currCalendar.r_begin_date_utc = _currCalendar.r_end_date_utc = _currCalendar.begindate_utc;
    //创建分段控件
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"一般事务",@"例行事务"]];
    _segmentedControl.frame = CGRectMake(0, 64, MAIN_SCREEN_WIDTH, 36);
    _segmentedControl.tintColor = [UIColor blackColor];
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentedControl];
    //创建表格视图
    _bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 100)];
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
    [_bottomScrollView addSubview:_repCalendarView];
    [self.view addSubview:_bottomScrollView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)segmentClicked:(UISegmentedControl*)seControl {
    [_bottomScrollView setContentOffset:CGPointMake(seControl.selectedSegmentIndex * _bottomScrollView.frame.size.width, 0) animated:YES];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    //创建日程
}
#pragma mark --
#pragma mark -- ComCalendarViewDelegate
//一般事务开始时间被点击
- (void)ComCalendarViewBegin {
    SelectDateController *select = [SelectDateController new];
    select.datePickerMode = _currCalendar.is_allday ? UIDatePickerModeDate : UIDatePickerModeDateAndTime;
    select.selectDateBlock = ^(NSDate *date) {
        _currCalendar.begindate_utc = [date timeIntervalSince1970] * 1000;
        _currCalendar.data = _currCalendar;
        _repCalendarView.data = _currCalendar;
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
        _currCalendar.data = _currCalendar;
        _repCalendarView.data = _currCalendar;
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
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
