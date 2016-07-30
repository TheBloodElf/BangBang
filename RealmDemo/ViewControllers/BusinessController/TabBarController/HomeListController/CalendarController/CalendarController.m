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
#import "CalendarCreateController.h"
#import "CalendarListController.h"
#import "ComCalendarDetailViewController.h"
#import "RepCalendarDetailController.h"

@interface CalendarController ()<RBQFetchedResultsControllerDelegate,JTCalendarDelegate,UITableViewDelegate,UITableViewDataSource,MoreSelectViewDelegate> {
    UserManager *_userManager;//用户管理器
    JTCalendarManager *_calendarManager;//日程管理器
    JTHorizontalCalendarView *_calendarContentView;//日历内容
    RBQFetchedResultsController *_calendarFetchedResultsController;//日程数据监听
    UITableView *_tableView;//表格视图
    NSMutableArray *_todayCalendarArr;//当天的日程
    NSMutableArray<NSDate*> *_haveCalendarArr;//有日程的时间数组
    NSDate *_userSelectedDate;//用户选择的时间
    MoreSelectView *_moreSelectView;//多选视图
    UILabel *_centerNavLabel;//导航中间视图
}
@end

@implementation CalendarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _haveCalendarArr = [@[] mutableCopy];
    _todayCalendarArr = [@[] mutableCopy];
    _userManager = [UserManager manager];
    self.view.backgroundColor = [UIColor whiteColor];
    _calendarFetchedResultsController = [_userManager createCalendarFetchedResultsController];
    _calendarFetchedResultsController.delegate = self;
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
    //创建日历管理器
    _userSelectedDate = [NSDate date];
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    _calendarManager.settings.weekModeEnabled = YES;
    _calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(0, 200, MAIN_SCREEN_WIDTH, 85)];
    _calendarContentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calendarContentView];
    _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatSingle;
    _calendarManager.contentView = _calendarContentView;
    [_calendarManager setDate:_userSelectedDate];
    //创建当天事件的表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 349 - 64, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 349 + 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    UILabel *noDataLabel = [[UILabel alloc] initWithFrame:_tableView.bounds];
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.text = @"正在加载数据...";
    noDataLabel.font = [UIFont systemFontOfSize:14];
    noDataLabel.textColor = [UIColor grayColor];
    _tableView.tableFooterView = noDataLabel;
    [_tableView registerNib:[UINib nibWithNibName:@"CalenderEventTableViewCell" bundle:nil] forCellReuseIdentifier:@"CalenderEventTableViewCell"];
    [self.view addSubview:_tableView];
    //创建中间导航视图
    _centerNavLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 17)];
    _centerNavLabel.font = [UIFont systemFontOfSize:17];
    _centerNavLabel.textAlignment = NSTextAlignmentCenter;
    _centerNavLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@(_userSelectedDate.year),@(_userSelectedDate.month)]];
    _centerNavLabel.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = _centerNavLabel;
    //创建右边导航
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(moreClicked:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCalendarClicked:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refushClicked:)],[[UIBarButtonItem alloc] initWithTitle:@"今" style:UIBarButtonItemStylePlain target:self action:@selector(todayClicked:)]];
    //创建多选视图
    _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100, 0, 100, 120)];
    _moreSelectView.selectArr = @[@"周视图",@"月视图",@"列表"];
    _moreSelectView.delegate = self;
    [_moreSelectView setupUI];
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor calendarColor];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //看是不是第一次加载日程
    IdentityManager *identity = [IdentityManager manager];
    if(identity.identity.firstLoadCalendar == YES) {
        [self.navigationController.view showLoadingTips:@"正在同步..."];
        //这里是软件自动从服务器拉取数据
        [UserHttp getUserCalendar:_userManager.user.user_guid handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSMutableArray *array = [@[] mutableCopy];
            for (NSDictionary *dic in data[@"list"]) {
                NSMutableDictionary *tempDic = [dic mutableCopy];
                [tempDic setValue:nil forKey:@"description"];
                Calendar *calendar = [Calendar new];
                [calendar mj_setKeyValues:tempDic];
                calendar.descriptionStr = dic[@"description"];
                [array addObject:calendar];
            }
            [_userManager updateCalendars:array];
            identity.identity.firstLoadCalendar = NO;
            [identity saveAuthorizeData];
            [self.navigationController.view showSuccessTips:@"同步成功"];
        }];
    } else {
        //先加载今天的数据
        [self loadHaveCalendarTimeArr];
        [_calendarManager reload];
        //加载有事件的日期，key-value格式
        [self getTodayCalendarArr];
        _tableView.tableFooterView = [UIView new];
        [_tableView reloadData];
    }
}
- (void)refushClicked:(UIBarButtonItem*)item {
//    [self.navigationController.view showLoadingTips:@"正在同步..."];
    //这里是用户向服务器提交数据
//    [UserHttp getUserCalendar:_userManager.user.user_guid handler:^(id data, MError *error) {
//        [self.navigationController.view dismissTips];
//        if(error) {
//            [self.navigationController.view showFailureTips:error.statsMsg];
//            return ;
//        }
//        NSMutableArray *array = [@[] mutableCopy];
//        for (NSDictionary *dic in data[@"list"]) {
//            Calendar *calendar = [[Calendar alloc] initWithJSONDictionary:dic];
//            calendar.descriptionStr = dic[@"description"];
//            [array addObject:calendar];
//        }
//        [_userManager updateCalendars:array];
//        [self.navigationController.view showSuccessTips:@"同步成功"];
//    }];
}
- (void)todayClicked:(UIBarButtonItem*)item {
    _userSelectedDate = [NSDate date];
    _centerNavLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@(_userSelectedDate.year),@(_userSelectedDate.month)]];
    [_calendarManager setDate:_userSelectedDate];
    [self getTodayCalendarArr];
    [_tableView reloadData];
}
//加载有日程的时间数组
- (void)loadHaveCalendarTimeArr {
    NSMutableArray *calendarArr = [_userManager getCalendarArr];
    [_haveCalendarArr removeAllObjects];
    for (Calendar *tempCalendar in calendarArr) {
        if(tempCalendar.repeat_type == 0) {//如果是不重复的日程
            if(tempCalendar.status == 1) {//如果是未完成的日程
                //先把今天加上
                NSDate *startTimeTemp = [NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc / 1000];
                if(![_haveCalendarArr containsObject:startTimeTemp])
                    [_haveCalendarArr addObject:startTimeTemp];
                if(tempCalendar.is_over_day == YES) {//如果是跨天的日程就要循环获取时间
                    do {
                        //加一天时间再判断
                        startTimeTemp = [startTimeTemp dateByAddingTimeInterval:24 * 60 * 60];
                        if(![_haveCalendarArr containsObject:startTimeTemp])
                            [_haveCalendarArr addObject:startTimeTemp];
                    } while (tempCalendar.enddate_utc >= ([startTimeTemp timeIntervalSince1970] + 24 * 60 * 60) * 1000);
                }
            }
        } else {//如果是重复的日程
            if(tempCalendar.status == 1) {//只算未完成的日程
                if(tempCalendar.rrule.length > 0 && tempCalendar.r_begin_date_utc>0 && tempCalendar.r_end_date_utc > 0) {
                    Scheduler * s = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc/1000] andRule:tempCalendar.rrule];
                    //得到所有的时间
                    NSArray * occurences = [s occurencesBetween:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_end_date_utc/1000]];
                    //每个时间都遍历一次
                    for (NSDate *tempDate in occurences) {
                        if([tempDate timeIntervalSince1970] < tempCalendar.r_begin_date_utc/1000) {
                            continue;
                        } else if ([tempCalendar haveDeleteDate:tempDate]) {
                            continue;
                        } else if ([tempCalendar haveFinishDate:tempDate]) {
                            continue;
                        } else {
                            if(![_haveCalendarArr containsObject:tempDate])
                                [_haveCalendarArr addObject:tempDate];
                        }
                    }
                }
            }
        }
    }
}
//获取当前的日程 完成的 和进行中的
- (void)getTodayCalendarArr {
    NSMutableArray *calendarArr = [_userManager getCalendarArrWithDate:_userSelectedDate];
    [_todayCalendarArr removeAllObjects];
    for (Calendar *tempCalendar in calendarArr) {
        if(tempCalendar.repeat_type == 0) {//不是重复的就直接加
            [_todayCalendarArr addObject:tempCalendar];
        } else {//重复的要加上经过自己一天的
            if (tempCalendar.rrule.length > 0&&tempCalendar.r_begin_date_utc >0&&tempCalendar.r_end_date_utc>0) {
                Scheduler * s = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc/1000] andRule:tempCalendar.rrule];
                //得到所有的时间
                NSArray * occurences = [s occurencesBetween:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_end_date_utc/1000]];
                for (NSDate *tempDate in occurences) {
                    if(tempDate.year == _userSelectedDate.year && tempDate.month == _userSelectedDate.month && tempDate.day == _userSelectedDate.day) {
                        if([tempCalendar haveDeleteDate:_userSelectedDate]) {
                            continue;
                        } else if([tempCalendar haveFinishDate:_userSelectedDate]) {
                            Calendar *calendar = [[Calendar alloc] initWithJSONDictionary:[tempCalendar JSONDictionary]];
                            calendar.rdate = _userSelectedDate.timeIntervalSince1970 / 1000;
                            calendar.status = 2;
                            [_todayCalendarArr addObject:calendar];
                        } else {
                            //这里把本次的触发时间加上
                            tempCalendar.rdate = _userSelectedDate.timeIntervalSince1970 / 1000;
                            [_todayCalendarArr addObject:tempCalendar];
                        }
                    }
                }
            }
        }
    }
}
- (void)addCalendarClicked:(UIBarButtonItem*)item {
    CalendarCreateController *calendar = [CalendarCreateController new];
    [self.navigationController pushViewController:calendar animated:YES];
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
    _tableView.tableFooterView = [UIView new];
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- MoreSelectViewDelegate
- (void)moreSelectIndex:(int)index {
    if(index == 0) {
        _calendarManager.settings.weekModeEnabled = YES;
        _calendarContentView.frame = CGRectMake(0, 200, MAIN_SCREEN_WIDTH, 85);
        [_calendarManager reload];
    } else if(index == 1) {
        _calendarManager.settings.weekModeEnabled = NO;
        _calendarContentView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 285);
        [_calendarManager reload];
    } else {
        CalendarListController *calendar = [CalendarListController new];
        [self.navigationController pushViewController:calendar animated:YES];
    }
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _todayCalendarArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalenderEventTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CalenderEventTableViewCell" forIndexPath:indexPath];
    cell.data = _todayCalendarArr[indexPath.row];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Calendar *calendar = _todayCalendarArr[indexPath.row];
    if(calendar.repeat_type == 0) {
        ComCalendarDetailViewController *com = [ComCalendarDetailViewController new];
        com.data = calendar;
        [self.navigationController pushViewController:com animated:YES];
    } else {
        RepCalendarDetailController *rep = [RepCalendarDetailController new];
        rep.data = calendar;
        [self.navigationController pushViewController:rep animated:YES];
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
    //是否有日程
    for (NSDate *tempDate in _haveCalendarArr) {
        NSString *str = [NSString stringWithFormat:@"%ld年%02ld月%02ld日",tempDate.year,tempDate.month,tempDate.day];
        if([str isEqualToString:[NSString stringWithFormat:@"%ld年%02ld月%02ld日",dayView.date.year,dayView.date.month,dayView.date.day]]) {
            dayView.dotView.hidden = NO;
            break;
        }
    }
    //当前显示灰色
    if(dayView.date.year == _userSelectedDate.year)
        if(dayView.date.month == _userSelectedDate.month)
            if(dayView.date.day == _userSelectedDate.day)
            {
                dayView.circleView.hidden = NO;
                dayView.circleView.backgroundColor = [UIColor grayColor];
                return;
            }
}
- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView {
    _userSelectedDate = dayView.date;
    [_calendarManager reload];
    [self getTodayCalendarArr];
    [_tableView reloadData];
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
