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

@interface CalendarController ()<RBQFetchedResultsControllerDelegate,JTCalendarDelegate,UITableViewDelegate,UITableViewDataSource,MoreSelectViewDelegate> {
    UserManager *_userManager;//用户管理器
    JTCalendarManager *_calendarManager;//日程管理器
    JTHorizontalCalendarView *_calendarContentView;//日历内容
    RBQFetchedResultsController *_calendarFetchedResultsController;//日程数据监听
    UITableView *_tableView;//表格视图
    NSMutableArray *_todayCalendarArr;//当天的日程
    NSDate *_userSelectedDate;//用户选择的时间
    MoreSelectView *_moreSelectView;//多选视图
    UILabel *_centerNavLabel;//导航中间视图
}
@end

@implementation CalendarController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    self.view.backgroundColor = [UIColor whiteColor];
    _calendarFetchedResultsController = [_userManager createCalendarFetchedResultsController];
    _calendarFetchedResultsController.delegate = self;
    //创建周视图时上面显示的视图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, MAIN_SCREEN_WIDTH, 200)];
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
    _calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(0, 264, MAIN_SCREEN_WIDTH, 85)];
    _calendarContentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calendarContentView];
    _calendarManager.settings.weekDayFormat = JTCalendarWeekDayFormatSingle;
    _calendarManager.contentView = _calendarContentView;
    [_calendarManager setDate:_userSelectedDate];
    //创建当天事件的表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 349, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 349) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"CalenderEventTableViewCell" bundle:nil] forCellReuseIdentifier:@"CalenderEventTableViewCell"];
    [self.view addSubview:_tableView];
    //创建中间导航视图
    _centerNavLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 17)];
    _centerNavLabel.font = [UIFont systemFontOfSize:17];
    _centerNavLabel.textAlignment = NSTextAlignmentCenter;
    _centerNavLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@(_userSelectedDate.year),@(_userSelectedDate.month)]];
    self.navigationItem.titleView = _centerNavLabel;
    //创建右边导航
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(moreClicked:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCalendarClicked:)],[[UIBarButtonItem alloc] initWithTitle:@"今" style:UIBarButtonItemStylePlain target:self action:@selector(todayClicked:)]];
    //创建多选视图
    _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100, 64, 100, 120)];
    _moreSelectView.selectArr = @[@"周视图",@"月视图",@"列表"];
    _moreSelectView.delegate = self;
    [_moreSelectView setupUI];
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
    //看是不是第一次加载日程
    IdentityManager *identity = [IdentityManager manager];
    if(identity.identity.firstLoadCalendar == YES) {
        [self.navigationController.view showLoadingTips:@"正在同步..."];
        [UserHttp getUserCalendar:_userManager.user.user_guid handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSMutableArray *array = [@[] mutableCopy];
            for (NSDictionary *dic in data[@"list"]) {
                Calendar *calendar = [Calendar new];
                [calendar mj_setKeyValues:dic];
                calendar.descriptionStr = dic[@"description"];
                [array addObject:calendar];
            }
            [_userManager updateCalendars:array];
            identity.identity.firstLoadCalendar = NO;
            [identity saveAuthorizeData];
            [self.navigationController.view showSuccessTips:@"同步成功"];
        }];
    }
    //先加载今天的数据
    _todayCalendarArr = [self getTodayCalendarArr];
    [_tableView reloadData];
}
- (void)todayClicked:(UIBarButtonItem*)item {
    _userSelectedDate = [NSDate date];
    _centerNavLabel.text = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@(_userSelectedDate.year),@(_userSelectedDate.month)]];
    [_calendarManager setDate:_userSelectedDate];
    [self getTodayCalendarArr];
    [_tableView reloadData];
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
    [_calendarManager reload];
    _todayCalendarArr = [self getTodayCalendarArr];
    [_tableView reloadData];
}
//获取当前的日程 分为跨天、全天、当天事件
- (NSMutableArray*)getTodayCalendarArr {
    return [@[@[],@[],@[]] mutableCopy];
}
//今天是否有日程安排
- (BOOL)todayHaveCalendar {
    return YES;
}
#pragma mark --
#pragma mark -- MoreSelectViewDelegate
- (void)moreSelectIndex:(int)index {
    if(index == 0) {
        _calendarManager.settings.weekModeEnabled = YES;
        _calendarContentView.frame = CGRectMake(0, 264, MAIN_SCREEN_WIDTH, 85);
        [_calendarManager reload];
    } else if(index == 1) {
        _calendarManager.settings.weekModeEnabled = NO;
        _calendarContentView.frame = CGRectMake(0, 64, MAIN_SCREEN_WIDTH, 285);
        [_calendarManager reload];
    } else {
        CalendarListController *calendar = [CalendarListController new];
        [self.navigationController pushViewController:calendar animated:YES];
    }
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_todayCalendarArr[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CalenderEventTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CalenderEventTableViewCell" forIndexPath:indexPath];
    cell.data = _todayCalendarArr[indexPath.section][indexPath.row];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSArray *headerImgArr = @[@"other_icon",@"next_icon",@"today_icon"];
    if (_todayCalendarArr.count > 0 && [[_todayCalendarArr objectAtIndex:section] count]> 0) {
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 25)];
        headerView.backgroundColor = [UIColor colorWithRed:242/255.f green:242/255.f blue:242/255.f alpha:1];
        UIImageView *headerImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:headerImgArr[section]]];
        headerImg.frame = CGRectMake(0, 5, headerImg.frame.size.width, headerImg.frame.size.height);
        [headerView addSubview:headerImg];
        return headerView;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_todayCalendarArr.count > 0 && [[_todayCalendarArr objectAtIndex:section] count] > 0) {
        return 22;
    }
    return 0;
}
#pragma mark --
#pragma mark -- JTCalendarDelegate
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView {
    dayView.circleView.hidden = YES;
    dayView.textLabel.textColor = [UIColor blackColor];
    if([dayView isFromAnotherMonth])
        dayView.textLabel.textColor = [UIColor grayColor];
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
