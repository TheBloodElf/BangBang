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
#import "NoResultView.h"
#import "ComCalendarDetailViewController.h"
#import "RepCalendarDetailController.h"

@interface CalendarListController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,RBQFetchedResultsControllerDelegate> {
    UITableView *_tableView;//表格视图
    UserManager *_userManager;//用户管理器
    UISearchBar *_searchBar;//搜索控件
    NoResultView *_noDataView;//没有数据的视图
    RBQFetchedResultsController *_calendarFetchedResultsController;
    NSArray<NSDate*> *_calendarDateArr;//时间数组
    NSMutableArray<NSMutableArray<Calendar*>*>* _calendarArr;//每个时间对应的日程数组
}
@end

@implementation CalendarListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"事务列表";
    _calendarDateArr = [@[] mutableCopy];
    _calendarArr = [@[] mutableCopy];
    _userManager = [UserManager manager];
    _calendarFetchedResultsController = [_userManager createCalendarFetchedResultsController];
    _calendarFetchedResultsController.delegate = self;
    
    //创建搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索日程";
    _searchBar.returnKeyType = UIReturnKeySearch;
    _searchBar.tintColor = [UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1];
    [_searchBar setSearchBarBackgroundColor:[UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1]];
    for(UIView * view in [_searchBar.subviews[0] subviews]) {
        if([view isKindOfClass:[UITextField class]]) {
            [(UITextField*)view setEnablesReturnKeyAutomatically:NO];
            break;
        }
    }
    [self.view addSubview:_searchBar];
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 55 - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _noDataView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    _tableView.tableFooterView = [UIView new];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[UINib nibWithNibName:@"CalenderEventTableViewCell" bundle:nil] forCellReuseIdentifier:@"CalenderEventTableViewCell"];
    [self.view addSubview:_tableView];
     [self searchTextFromLoc];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [self searchTextFromLoc];
}
//本地加载所有事件
- (void)searchTextFromLoc {
    dispatch_async(dispatch_get_main_queue(), ^{
        //时间 时间对应的日程
        NSMutableDictionary<NSDate*,NSMutableArray<Calendar*>*> *dateCalendarDic = [@{} mutableCopy];
        for (Calendar *tempCalendar in [_userManager getCalendarArr]) {
            if(![NSString isBlank:_searchBar.text])
                if([tempCalendar.event_name rangeOfString:_searchBar.text].location == NSNotFound) continue;
            if(tempCalendar.repeat_type == 0) {//如果是不重复的日程
                //先把今天加上
                NSDate *startTimeTemp = [NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc / 1000];
                if([dateCalendarDic.allKeys containsObject:startTimeTemp]) {//如果已经有这个值了
                    //是否初始化了对应的value
                    if(dateCalendarDic[startTimeTemp]) {
                        [dateCalendarDic[startTimeTemp] addObject:tempCalendar];
                    } else {
                        [dateCalendarDic setObject:[@[tempCalendar] mutableCopy] forKey:startTimeTemp];
                    }
                } else {//没有这个值就设置一个键值对
                    [dateCalendarDic setObject:[@[tempCalendar] mutableCopy] forKey:startTimeTemp];
                }
                if(tempCalendar.is_over_day == YES) {//如果是跨天的日程就要循环获取时间
                    do {
                        //加一天时间再判断
                        startTimeTemp = [startTimeTemp dateByAddingTimeInterval:24 * 60 * 60];
                        if([dateCalendarDic.allKeys containsObject:startTimeTemp]) {//如果已经有这个值了
                            //是否初始化了对应的value
                            if(dateCalendarDic[startTimeTemp]) {
                                [dateCalendarDic[startTimeTemp] addObject:tempCalendar];
                            } else {
                                [dateCalendarDic setObject:[@[tempCalendar] mutableCopy] forKey:startTimeTemp];
                            }
                        } else {//没有这个值就设置一个键值对
                            [dateCalendarDic setObject:[@[tempCalendar] mutableCopy] forKey:startTimeTemp];
                        }
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
                        } else if ([tempCalendar haveDeleteDate:tempDate]) {//删除的不管
                            continue;
                        } else if([tempCalendar haveFinishDate:tempDate]) {//完成的就要改变状态后再加
                            Calendar *calendar = [tempCalendar deepCopy];
                            calendar.status = 2;
                            if([dateCalendarDic.allKeys containsObject:tempDate]) {//如果已经有这个值了
                                //是否初始化了对应的value
                                if(dateCalendarDic[tempDate]) {
                                    [dateCalendarDic[tempDate] addObject:calendar];
                                } else {
                                    [dateCalendarDic setObject:[@[calendar] mutableCopy] forKey:tempDate];
                                }
                            } else {//没有这个值就设置一个键值对
                                [dateCalendarDic setObject:[@[calendar] mutableCopy] forKey:tempDate];
                            }

                        }  else {//未完成的日程
                            Calendar *calendar = [tempCalendar deepCopy];
                            calendar.rdate = @(tempDate.timeIntervalSince1970).stringValue;//加上本次触发的时间
                            if([dateCalendarDic.allKeys containsObject:tempDate]) {//如果已经有这个值了
                                //是否初始化了对应的value
                                if(dateCalendarDic[tempDate]) {
                                    [dateCalendarDic[tempDate] addObject:calendar];
                                } else {
                                    [dateCalendarDic setObject:[@[calendar] mutableCopy] forKey:tempDate];
                                }
                            } else {//没有这个值就设置一个键值对
                                [dateCalendarDic setObject:[@[calendar] mutableCopy] forKey:tempDate];
                            }
                        }
                    }
                }
            }
        }
        _calendarDateArr = dateCalendarDic.allKeys;
        _calendarDateArr = [_calendarDateArr sortedArrayUsingComparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
            return obj1.timeIntervalSince1970 < obj2.timeIntervalSince1970;
        }];
        [_calendarArr removeAllObjects];
        for (NSDate *date in _calendarDateArr) {
            [_calendarArr addObject:dateCalendarDic[date]];
        }
        if(_calendarDateArr.count == 0)
            _tableView.tableFooterView = _noDataView;
        else
            _tableView.tableFooterView = [UIView new];
        [_tableView reloadData];
    });
}
#pragma mark --
#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    [self searchTextFromLoc];
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
    NSDate *date = _calendarDateArr[section];
    return [NSString stringWithFormat:@"%d-%d-%d %@",date.year,date.month,date.day,[date weekdayStr]];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _calendarDateArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _calendarArr[section].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalenderEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalenderEventTableViewCell" forIndexPath:indexPath];
    cell.data = _calendarArr[indexPath.section][indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.alpha = 0;
    [UIView animateWithDuration:0.6 animations:^{
        view.alpha = 1;
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Calendar *calendar = _calendarArr[indexPath.section][indexPath.row];
    UIViewController *vc = nil;
    if(calendar.repeat_type == 0)
        vc = [ComCalendarDetailViewController new];
    else
        vc = [RepCalendarDetailController new];
    vc.data = calendar;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
