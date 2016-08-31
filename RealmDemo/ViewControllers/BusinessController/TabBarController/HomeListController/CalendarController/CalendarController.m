//
//  CalendarController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CalendarController.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "MoreSelectView.h"
#import "CalenderEventTableViewCell.h"
#import "IdentityManager.h"
#import "NoResultView.h"
#import "CalendarListController.h"
#import "CalendarCreateController.h"
#import "ComCalendarDetailViewController.h"
#import "RepCalendarDetailController.h"

@interface CalendarController ()<RBQFetchedResultsControllerDelegate,JTCalendarDelegate,UITableViewDelegate,UITableViewDataSource,MoreSelectViewDelegate> {
    UserManager *_userManager;//用户管理器
    JTCalendarManager *_calendarManager;//日程管理器
    JTHorizontalCalendarView *_calendarContentView;//日历内容
    RBQFetchedResultsController *_calendarFetchedResultsController;//日程数据监听
    UITableView *_tableView;//表格视图
    NSMutableArray<Calendar*> *_todayAlldayCalendarArr;//当天全天的日程
    NSMutableArray<Calendar*> *_todayOverdayCalendarArr;//当天跨天的日程
    NSMutableArray<Calendar*> *_todayOtherCalendarArr;//当天一般的日程
    NSMutableArray<NSDate*> *_haveCalendarArr;//有日程的时间数组
    NSDate *_userSelectedDate;//用户选择的时间
    MoreSelectView *_moreSelectView;//多选视图
    UILabel *_centerNavLabel;//导航中间视图
    NoResultView *_noDataView;//没有数据显示的视图
    
    BOOL isFirstLoad;
}
@end

@implementation CalendarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _haveCalendarArr = [@[] mutableCopy];
    _todayAlldayCalendarArr = [@[] mutableCopy];
    _todayOverdayCalendarArr = [@[] mutableCopy];
    _todayOtherCalendarArr = [@[] mutableCopy];
    _userManager = [UserManager manager];
    self.view.backgroundColor = [UIColor whiteColor];
    _calendarFetchedResultsController = [_userManager createCalendarFetchedResultsController];
    _calendarFetchedResultsController.delegate = self;
    _userSelectedDate = [NSDate date];
    //创建中间导航视图
    _centerNavLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 17)];
    _centerNavLabel.font = [UIFont systemFontOfSize:17];
    _centerNavLabel.textAlignment = NSTextAlignmentCenter;
    _centerNavLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@(_userSelectedDate.year),@(_userSelectedDate.month)]];
    _centerNavLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = _centerNavLabel;
    //创建周视图时上面显示的视图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 200)];
    imageView.image = [UIImage imageNamed:@"calendar_list_background"];
    [self.view addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 87.5, MAIN_SCREEN_WIDTH, 25)];
    label.font = [UIFont systemFontOfSize:25];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"Welcome!";
    [imageView addSubview:label];
    //创建右边导航
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(moreClicked:)];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor calendarColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //是不是第一次加载这个页面
    if(isFirstLoad) return;
    isFirstLoad = YES;
    
    //创建日历管理器
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekModeEnabled = YES;
    _calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(0, 200, MAIN_SCREEN_WIDTH, 85)];
    _calendarContentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calendarContentView];
    _calendarManager.contentView = _calendarContentView;
    [_calendarManager setDate:_userSelectedDate];
    //添加上下滑动的手势
    _calendarContentView.userInteractionEnabled = YES;
    UISwipeGestureRecognizer *swTop = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(topClicked:)];
    swTop.direction = UISwipeGestureRecognizerDirectionUp;
    [_calendarContentView addGestureRecognizer:swTop];
    UISwipeGestureRecognizer *swDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(downClicked:)];
    swDown.direction = UISwipeGestureRecognizerDirectionDown;
    [_calendarContentView addGestureRecognizer:swDown];
    //创建当天事件的表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 349 - 64, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 349) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"CalenderEventTableViewCell" bundle:nil] forCellReuseIdentifier:@"CalenderEventTableViewCell"];
    _noDataView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    [self.view addSubview:_tableView];
   
    //创建多选视图
    _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100, 0, 100, 160)];
    _moreSelectView.selectArr = @[@"今天",@"日程列表",@"添加日程",@"同步日程"];
    _moreSelectView.delegate = self;
    [_moreSelectView setupUI];
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
    
    //加载有事件的日期，key-value格式
     NSMutableArray *calendarArr = [_userManager getCalendarArr];
    if(calendarArr.count == 0)
        [self tongBuCalendar];
    else {
        //先加载今天的数据
        [self loadHaveCalendarTimeArr];
        [_calendarManager reload];
        [self getTodayCalendarArr];
    }
}
- (void)topClicked:(UISwipeGestureRecognizer*)sw {
    [UIView animateWithDuration:0.2 animations:^{
        _calendarManager.settings.weekModeEnabled = NO;
        _calendarContentView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 285);
        [_calendarManager reload];
    }];
}
- (void)downClicked:(UISwipeGestureRecognizer*)sw {
    [UIView animateWithDuration:0.2 animations:^{
        _calendarManager.settings.weekModeEnabled = YES;
        _calendarContentView.frame = CGRectMake(0, 200, MAIN_SCREEN_WIDTH, 85);
        [_calendarManager reload];
    }];
}
//加载有日程的时间数组
- (void)loadHaveCalendarTimeArr {
    NSMutableArray *calendarArr = [_userManager getCalendarArr];
    [_haveCalendarArr removeAllObjects];
    for (Calendar *tempCalendar in calendarArr) {
        if(tempCalendar.status != 1) continue;
        if(tempCalendar.repeat_type == 0) {//如果是不重复的日程
            for (int64_t startTime = tempCalendar.begindate_utc; startTime <= tempCalendar.enddate_utc; startTime += (24 * 60 * 60 * 1000)) {
                NSDate *startTimeTemp = [NSDate dateWithTimeIntervalSince1970:startTime / 1000];
                if(![_haveCalendarArr containsObject:startTimeTemp])
                    [_haveCalendarArr addObject:startTimeTemp];
            }
        } else {//如果是重复的日程
            Scheduler * scheduler = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc/1000] andRule:tempCalendar.rrule];
            //得到所有的时间
            NSArray * occurences = [scheduler occurencesBetween:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_end_date_utc/1000]];
            //每个时间都遍历一次
            for (NSDate *tempDate in occurences) {
                if([tempDate timeIntervalSince1970] < tempCalendar.r_begin_date_utc/1000) continue;
                if ([tempCalendar haveDeleteDate:tempDate]) continue;
                if ([tempCalendar haveFinishDate:tempDate]) continue;
                if(![_haveCalendarArr containsObject:tempDate])
                    [_haveCalendarArr addObject:tempDate];
            }
        }
    }
}
//获取用户所选日期的的日程
- (void)getTodayCalendarArr {
    NSMutableArray *calendarArr = [_userManager getCalendarArrWithDate:_userSelectedDate];
    [_todayOtherCalendarArr removeAllObjects];
    [_todayAlldayCalendarArr removeAllObjects];
    [_todayOverdayCalendarArr removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (Calendar *tempCalendar in calendarArr) {
            if(tempCalendar.repeat_type == 0) {//不是重复的就直接加
                if(tempCalendar.is_allday == YES)
                    [_todayAlldayCalendarArr addObject:tempCalendar];
                else if (tempCalendar.enddate_utc - tempCalendar.begindate_utc > (24 * 60 * 60 * 1000))
                    [_todayOverdayCalendarArr addObject:tempCalendar];
                else
                    [_todayOtherCalendarArr addObject:tempCalendar];
            } else {//重复的要加上经过自己一天的
                Scheduler * s = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc/1000] andRule:tempCalendar.rrule];
                //得到所有的时间
                NSArray * occurences = [s occurencesBetween:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_end_date_utc/1000]];
                for (NSDate *tempDate in occurences) {
                    //值加载今天的日程
                    if(tempDate.year == _userSelectedDate.year && tempDate.month == _userSelectedDate.month && tempDate.day == _userSelectedDate.day) {
                        if([tempCalendar haveDeleteDate:tempDate]) continue;
                        if([tempCalendar haveFinishDate:tempDate] || tempCalendar.status == 2) {//当前已完成
                            Calendar *calendar = [tempCalendar deepCopy];
                            calendar.status = 2;
                            if(calendar.is_allday == YES)
                                [_todayAlldayCalendarArr addObject:calendar];
                            else if (calendar.r_end_date_utc - calendar.r_begin_date_utc > (24 * 60 * 60 * 1000))
                                [_todayOverdayCalendarArr addObject:calendar];
                            else
                                [_todayOtherCalendarArr addObject:calendar];
                        } else {//当前未完成
                            Calendar *calendar = [tempCalendar deepCopy];
                            calendar.rdate = @(tempDate.timeIntervalSince1970).stringValue;
                            if(calendar.is_allday == YES)
                                [_todayAlldayCalendarArr addObject:calendar];
                            else if (calendar.r_end_date_utc - calendar.r_begin_date_utc > (24 * 60 * 60 * 1000))
                                [_todayOverdayCalendarArr addObject:calendar];
                            else
                                [_todayOtherCalendarArr addObject:calendar];
                        }
                    }
                }
            }
        }
        if(_todayOtherCalendarArr.count == 0 && _todayAlldayCalendarArr.count == 0 && _todayOverdayCalendarArr.count == 0)
            _tableView.tableFooterView = _noDataView;
        else
            _tableView.tableFooterView = [UIView new];
         [_tableView reloadData];
    });
}
- (void)moreClicked:(UIBarButtonItem*)item {
    if(_moreSelectView.isHide)
        [_moreSelectView showSelectView];
    else
        [_moreSelectView hideSelectView];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    //刷新当前的事件表格视图，重新加载一次日历视图
    [self loadHaveCalendarTimeArr];
    [_calendarManager reload];
    [self getTodayCalendarArr];
}
#pragma mark --
#pragma mark -- MoreSelectViewDelegate
- (void)moreSelectIndex:(int)index {
    if(index == 0) {
        _userSelectedDate = [NSDate date];
        [_calendarManager setDate:_userSelectedDate];
        [self getTodayCalendarArr];
    } else if(index == 1) {
        [self.navigationController pushViewController:[CalendarListController new] animated:YES];
    } else if (index == 2) {
        [self.navigationController pushViewController:[CalendarCreateController new] animated:YES];
    } else {
        [self tongBuCalendar];
    }
}
- (void)tongBuCalendar {
    [self.navigationController.view showLoadingTips:@"正在同步..."];
    WeakSelf(weakSelf)
    //    这里是用户向服务器提交数据 现在还没有改
    [UserHttp getUserCalendar:_userManager.user.user_guid handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [weakSelf.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *dic in data[@"list"]) {
            Calendar *calendar = [[Calendar alloc] initWithJSONDictionary:dic];
            calendar.descriptionStr = dic[@"description"];
            [array addObject:calendar];
        }
        [_userManager updateCalendars:array];
        [weakSelf.navigationController.view showSuccessTips:@"同步成功"];
    }];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return _todayAlldayCalendarArr.count ? 20 : 0.01;
    if(section == 1)
        return _todayOverdayCalendarArr.count ? 20 : 0.01;
    return _todayOtherCalendarArr.count ? 20 : 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return _todayAlldayCalendarArr.count ? @"全天" : @"";;
    if(section == 1)
        return _todayOverdayCalendarArr.count ? @"跨天" : @"";
    return _todayOtherCalendarArr.count ? @"一般" : @"";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return _todayAlldayCalendarArr.count;
    if(section == 1)
        return _todayOverdayCalendarArr.count;
    return _todayOtherCalendarArr.count;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.alpha = 0;
    [UIView animateWithDuration:0.6 animations:^{
        view.alpha = 1;
    }];
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.alpha = 0;
    [UIView animateWithDuration:0.6 animations:^{
        cell.alpha = 1;
    }];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalenderEventTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CalenderEventTableViewCell" forIndexPath:indexPath];
    if(indexPath.section == 0)
        cell.data = _todayAlldayCalendarArr[indexPath.row];
    else if(indexPath.section == 1)
        cell.data = _todayOverdayCalendarArr[indexPath.row];
    else
        cell.data = _todayOtherCalendarArr[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Calendar *calendar = nil;
    if(indexPath.section == 0)
        calendar = _todayAlldayCalendarArr[indexPath.row];
    else if(indexPath.section == 1)
        calendar = _todayOverdayCalendarArr[indexPath.row];
    else
        calendar = _todayOtherCalendarArr[indexPath.row];
    if(calendar.repeat_type == 0) {
        RepCalendarDetailController *vc = [ComCalendarDetailViewController new];
        vc.data = calendar;
        [self.navigationController pushViewController:vc animated:YES];
        
    } else {
        RepCalendarDetailController *vc = [RepCalendarDetailController new];
        vc.data = calendar;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}
#pragma mark --
#pragma mark -- JTCalendarDelegate
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView {
    dayView.circleView.hidden = YES;
    dayView.dotView.hidden = YES;
    dayView.textLabel.textColor = [UIColor blackColor];
    if([dayView isFromAnotherMonth])
        dayView.textLabel.textColor = [UIColor grayColor];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //是否有日程
        for (NSDate *tempDate in _haveCalendarArr) {
            if(tempDate.year == dayView.date.year)
            if(tempDate.month == dayView.date.month)
            if(tempDate.day == dayView.date.day) {
            dispatch_async(dispatch_get_main_queue(), ^{
                dayView.dotView.hidden = NO;
            });
            break;
            }
        }
    });
    //当前显示灰色
    if(dayView.date.year == _userSelectedDate.year)
    if(dayView.date.month == _userSelectedDate.month)
    if(dayView.date.day == _userSelectedDate.day) {
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor calendarColor];
    }
}
- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView {
    _userSelectedDate = dayView.date;
    [_calendarManager setDate:_userSelectedDate];
    [self getTodayCalendarArr];
}
- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar;
{
   _centerNavLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@(calendar.date.year),@(calendar.date.month)]];
}
- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
   _centerNavLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@(calendar.date.year),@(calendar.date.month)]];
}
@end
