//
//  CalendarListController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CalendarListController.h"
#import "CalenderEventTableViewCell.h"
#import "UserManager.h"
#import "ComCalendarDetailViewController.h"
#import "RepCalendarDetailController.h"

@interface CalendarListController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,RBQFetchedResultsControllerDelegate> {
    UITableView *_tableView;//表格视图
    UserManager *_userManager;//用户管理器
    UISearchBar *_searchBar;//搜索控件
    UIView *_noDataView;//没有数据的视图
    RBQFetchedResultsController *_calendarFetchedResultsController;
    NSMutableDictionary<NSDate*,NSMutableArray<Calendar*>*> *_dataDic;//展示数据的字典
}
@end

@implementation CalendarListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"事务列表";
    _userManager = [UserManager manager];
    _calendarFetchedResultsController = [_userManager createCalendarFetchedResultsController];
    _calendarFetchedResultsController.delegate = self;
    _dataDic = [@{} mutableCopy];
    //创建搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索日程";
    [self.view addSubview:_searchBar];
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 55) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    UILabel *noDataLabel = [[UILabel alloc] initWithFrame:_tableView.bounds];
    noDataLabel.textAlignment = NSTextAlignmentCenter;
    noDataLabel.text = @"正在加载数据...";
    noDataLabel.font = [UIFont systemFontOfSize:14];
    noDataLabel.textColor = [UIColor grayColor];
    _tableView.tableFooterView = noDataLabel;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[UINib nibWithNibName:@"CalenderEventTableViewCell" bundle:nil] forCellReuseIdentifier:@"CalenderEventTableViewCell"];
    [self.view addSubview:_tableView];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self searchTextFromLoc];
    _tableView.tableFooterView = [UIView new];
    [_tableView reloadData];
}
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [self searchTextFromLoc];
    [_tableView reloadData];
}
//本地加载所有事件
- (void)searchTextFromLoc {
    NSMutableArray *_haveCalendarArr = [@[] mutableCopy];
    NSMutableArray *calendarArr = [_userManager getCalendarArr];
    for (Calendar *tempCalendar in calendarArr) {
        //是不是包含搜索关键字
        if([tempCalendar.event_name rangeOfString:_searchBar.text].location == NSNotFound)
            continue;
        if(tempCalendar.repeat_type == 0) {//如果是不重复的日程
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
        } else {//如果是重复的日程
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
    //每个日程时间都加上对应的日程
    [_haveCalendarArr sortUsingComparator:^NSComparisonResult(NSDate*  _Nonnull obj1, NSDate*  _Nonnull obj2) {
        return (obj2.timeIntervalSince1970 - obj1.timeIntervalSince1970) > 0;
    }];
    for (NSDate *date in _haveCalendarArr) {
        [_dataDic setObject:[self getCalendarArrWithDate:date] forKey:date];
    }
}
- (NSMutableArray<Calendar*>*)getCalendarArrWithDate:(NSDate*)date {
    NSMutableArray *calendarArr = [_userManager getCalendarArrWithDate:date];
    NSMutableArray *_todayCalendarArr = [@[] mutableCopy];
    for (Calendar *tempCalendar in calendarArr) {
        if(tempCalendar.repeat_type == 0) {//不是重复的就直接加
            [_todayCalendarArr addObject:tempCalendar];
        } else {//重复的要加上经过自己一天的
            if (tempCalendar.rrule.length > 0&&tempCalendar.r_begin_date_utc >0&&tempCalendar.r_end_date_utc>0) {
                Scheduler * s = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc/1000] andRule:tempCalendar.rrule];
                //得到所有的时间
                NSArray * occurences = [s occurencesBetween:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_end_date_utc/1000]];
                for (NSDate *tempDate in occurences) {
                    if(tempDate.year == date.year && tempDate.month == date.month && tempDate.day == date.day) {
                        if([tempCalendar haveDeleteDate:tempDate]) {
                            continue;
                        } else if([tempCalendar haveFinishDate:tempDate]) {
                            Calendar *calendar = [[Calendar alloc] initWithJSONDictionary:[tempCalendar JSONDictionary]];
                            calendar.status = 2;
                            [_todayCalendarArr addObject:calendar];
                        } else {
                            [_todayCalendarArr addObject:tempCalendar];
                        }
                    }
                }
            }
        }
    }
    return _todayCalendarArr;
}
#pragma mark --
#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    [self searchTextFromLoc];
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDate *date = _dataDic.allKeys[section];
    return [NSString stringWithFormat:@"%d-%d-%d %@",date.year,date.month,date.day,[date weekdayStr]];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataDic.allKeys.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataDic[_dataDic.allKeys[section]] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalenderEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalenderEventTableViewCell" forIndexPath:indexPath];
    cell.data = _dataDic[_dataDic.allKeys[indexPath.section]][indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Calendar *calendar = _dataDic[_dataDic.allKeys[indexPath.section]][indexPath.row];
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
@end
