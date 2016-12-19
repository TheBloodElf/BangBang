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
    _currCalendar.event_name = @"";
    _currCalendar.company_no = _userManager.user.currCompany.company_no;
    //计算当前应该显示的时间 30分钟为单位
    int64_t second = (self.createDate ? : [NSDate date]).timeIntervalSince1970;
    if((second % (30 * 60)) != 0)
        second = (second / (30 * 60)) * (30 * 60) + 30 * 60;
    _currCalendar.begindate_utc = second * 1000;
    _currCalendar.enddate_utc = second * 1000 + 30 * 60 * 1000;
    _currCalendar.repeat_type = 0;//先不重复
    _currCalendar.alert_minutes_after = 0;
    _currCalendar.alert_minutes_before = 0;
    _currCalendar.is_alert = false;
    _currCalendar.is_allday = false;
    _currCalendar.status = 1;
    _currCalendar.user_guid = _userManager.user.user_guid;
    _currCalendar.created_by = _userManager.user.user_guid;
    _currCalendar.updated_by = _userManager.user.user_guid;
    _currCalendar.emergency_status = 0;
    _currCalendar.r_begin_date_utc = _currCalendar.r_end_date_utc = _currCalendar.begindate_utc;
    _currCalendar.app_guid = @"";
    _currCalendar.rrule = @"";
    _currCalendar.is_over_day = NO;
    _currCalendar.descriptionStr = @"";
    _currCalendar.address = @"";
    _currCalendar.target_id = @"";
    _currCalendar.rdate = @"";
    _currCalendar.members = @"";
    _currCalendar.member_names= @"";
    _currCalendar.event_guid = @"";
    _currCalendar.deleted_dates = @"";
    _currCalendar.finished_dates = @"";
    _currCalendar.creator_name = _userManager.user.real_name;
    //创建分段控件
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"一般事务",@"例行事务"]];
    _segmentedControl.frame = CGRectMake(10, 5, MAIN_SCREEN_WIDTH - 20, 30);
    _segmentedControl.tintColor = [UIColor calendarColor];
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.backgroundColor = [UIColor whiteColor];
    UIView *bagView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 35)];
    bagView.backgroundColor = [UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1];
    [self.view addSubview:bagView];
    [self.view addSubview:_segmentedControl];
    //创建表格视图
    _bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 35, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 35)];
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftClicked:)];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor calendarColor];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
- (void)segmentClicked:(UISegmentedControl*)seControl {
    [_bottomScrollView setContentOffset:CGPointMake(seControl.selectedSegmentIndex * _bottomScrollView.frame.size.width, 0) animated:YES];
    if(seControl.selectedSegmentIndex == 0) {
        _currCalendar.repeat_type = 0;
        _currCalendar.rrule = @"";
    } else {
        //切换到例行日程创建就默认重复周期为每天
        _currCalendar.repeat_type = 1;
        _currCalendar.rrule = @"FREQ=DAILY;INTERVAL=1";
    }
}
- (void)leftClicked:(UIBarButtonItem*)item {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    [self.view endEditing:YES];
    if([NSString isBlank:_currCalendar.event_name]) {
        [self.navigationController.view showMessageTips:@"请填写事务名称"];
        return;
    }
    if(_currCalendar.repeat_type == 0) {
        if(_currCalendar.enddate_utc < _currCalendar.begindate_utc) {
            [self.navigationController.view showMessageTips:@"开始时间不能晚于结束时间"];
            return;
        }
    } else {
        if(_currCalendar.r_end_date_utc < _currCalendar.r_begin_date_utc) {
            [self.navigationController.view showMessageTips:@"重复开始时间不能晚于重复结束时间"];
            return;
        }
        int64_t second = _currCalendar.r_begin_date_utc / 1000;
        second = second / (24 * 60 * 60) * (24 * 60 * 60);
        second += (_currCalendar.begindate_utc / 1000) % (24 * 60 * 60);
        Scheduler * s = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:second] andRule:_currCalendar.rrule];
        //得到所有的时间 起始时间不会算在里面（*）
        NSArray * occurences = [s occurencesBetween:[NSDate dateWithTimeIntervalSince1970:_currCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:_currCalendar.r_end_date_utc/1000]];
        int count = (int) occurences.count;
        if(count == 0) {
            [self.navigationController.view showMessageTips:@"重复间隔应小于重复时间段"];
            return;
        }
        NSDate *firstDate = occurences[0];
        //这个库算出来的结果可能会有之前的时间，现在去掉
        if(firstDate.timeIntervalSince1970 < (_currCalendar.r_begin_date_utc / 1000))
            count -- ;
        NSDate *lastDate = occurences.lastObject;
        //这个库算出来的结果可能会有之后的时间，现在去掉
        if(lastDate.timeIntervalSince1970 > (_currCalendar.r_end_date_utc / 1000))
            count --;
        if(count == 0) {
            [self.navigationController.view showMessageTips:@"重复间隔应小于重复时间段"];
            return;
        }
    }
    //如果有分享者 则需要加上自己
    NSArray *guidArr = [_currCalendar.members componentsSeparatedByString:@","];
    for (NSString *guid in guidArr) {
        if(![NSString isBlank:guid]) {
            _currCalendar.members = [_currCalendar.members stringByAppendingString:[NSString stringWithFormat:@",%@",_userManager.user.user_guid]];
            break;
        }
    }
    //创建日程
    [self.navigationController.view showLoadingTips:@""];
    [UserHttp createUserCalendar:_currCalendar handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            if(error.statsCode == -1009) {
                _currCalendar.needSync = YES;
                _currCalendar.id = -[NSDate date].timeIntervalSince1970;
                _currCalendar.createdon_utc = [NSDate date].timeIntervalSince1970 * 1000;
                _currCalendar.updatedon_utc = [NSDate date].timeIntervalSince1970 * 1000;
                [_userManager addCalendar:_currCalendar];
                _currCalendar.finishedon_utc = [NSDate date].timeIntervalSince1970 * 1000;
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        Calendar *calendar = [Calendar new];
        [calendar mj_setKeyValues:data];
        calendar.descriptionStr = data[@"description"];
        [_userManager addCalendar:calendar];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
#pragma mark --
#pragma mark -- RepCalendarViewDelegate
//例行开始时间
- (void)RepCalendarViewBegin {
    SelectDateController *select = [SelectDateController new];
    select.needShowDate = [NSDate dateWithTimeIntervalSince1970:_currCalendar.begindate_utc / 1000];
    select.datePickerMode = UIDatePickerModeTime;
    select.selectDateBlock = ^(NSDate *date) {
        _currCalendar.begindate_utc = [date timeIntervalSince1970] * 1000;
        //结束时间自动加30分钟
        _currCalendar.enddate_utc = [date timeIntervalSince1970] * 1000 + 1000 * 30 * 60;
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
    select.needShowDate = [NSDate dateWithTimeIntervalSince1970:_currCalendar.enddate_utc / 1000];
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
    select.userSelectEKRecurrenceRule = [[EKRecurrenceRule alloc] initWithString:_currCalendar.rrule];
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
    select.needShowDate = [NSDate dateWithTimeIntervalSince1970:_currCalendar.r_begin_date_utc / 1000];
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
    select.needShowDate = [NSDate dateWithTimeIntervalSince1970:_currCalendar.r_end_date_utc / 1000];
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
    select.needShowDate = [NSDate dateWithTimeIntervalSince1970:_currCalendar.begindate_utc / 1000];
    select.datePickerMode = _currCalendar.is_allday ? UIDatePickerModeDate : UIDatePickerModeDateAndTime;
    select.selectDateBlock = ^(NSDate *date) {
        _currCalendar.begindate_utc = [date timeIntervalSince1970] * 1000;
        _comCalendarView.data = _currCalendar;
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
    select.userSelectTime = _currCalendar.alert_minutes_after;
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
//    //第一种写法：不太好，三个for循环
//    //添加加入的所有圈子的员工
//    NSMutableArray<Employee*> *allCompanysEmployees = [@[] mutableCopy];
//    //便利所有圈子
//    for (Company *company in [_userManager getCompanyArr]) {
//        //获取自己在该圈子中的员工
//        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
//        //只显示自己状态为4或者1的
//        if(employee.status == 1 || employee.status == 4) {
//            //遍历该圈子的所有员工
//            NSArray<Employee*> *employees = [_userManager getEmployeeWithCompanyNo:company.company_no status:5];
//            for (Employee *tempEmployee in employees) {
//                //排除自己（因为"分享给："不需要自己，提交的时候才加上自己）
//                if([tempEmployee.user_guid isEqualToString:employee.user_guid])
//                    continue;
//                //排除已经有这个user_guid的
//                for (Employee *temp in allCompanysEmployees)
//                    if([temp.user_guid isEqualToString:tempEmployee.user_guid])
//                        continue;
//                [allCompanysEmployees addObject:tempEmployee];
//            }
//        }
//    }
//    //第二种写法：要好一点了
//    //添加加入的所有圈子的员工
//    NSMutableArray<Employee*> *allCompanysEmployees = [@[] mutableCopy];
//    //用来装已经有的user_guid
//    NSMutableArray<NSString*> *userGuids = [@[_userManager.user.user_guid] mutableCopy];
//    //便利所有圈子
//    for (Company *company in [_userManager getCompanyArr]) {
//        //获取自己在该圈子中的员工
//        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
//        //只显示自己状态为4或者1的
//        if(employee.status == 1 || employee.status == 4) {
//            //遍历该圈子的所有员工
//            NSArray<Employee*> *employees = [_userManager getEmployeeWithCompanyNo:company.company_no status:5];
//            for (Employee *tempEmployee in employees) {
//                //排除已经有这个user_guid的
//                if([userGuids containsObject:tempEmployee.user_guid])
//                    continue;
//                [userGuids addObject:tempEmployee.user_guid];
//                [allCompanysEmployees addObject:tempEmployee];
//            }
//        }
//    }
    //第三种写法：字典天生去重复
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
//    //第三四写法：网上看到的黑科技 但是只能得到基本类型数组
//    //添加加入的所有圈子的员工
//    NSMutableArray<Employee*> *employees = [@[] mutableCopy];
//    //便利所有圈子
//    for (Company *company in [_userManager getCompanyArr]) {
//        //获取自己在该圈子中的员工
//        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
//        //只显示自己状态为4或者1的
//        if(employee.status == 1 || employee.status == 4) {
//            //遍历该圈子的所有员工
//            for (Employee *tempEmployee in [_userManager getEmployeeWithCompanyNo:company.company_no status:5]) {
//                if([tempEmployee.user_guid isEqualToString:employee.user_guid])
//                    continue;
//                [employees addObject:tempEmployee];
//            }
//        }
//    }
//    mulite.discussMember = [[employees valueForKeyPath:@"@distinctUnionOfObjects.user_guid"] mutableCopy];//表示获取对象的user_guid组成数组返回
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
