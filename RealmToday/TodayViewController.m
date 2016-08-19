//
//  TodayViewController.m
//  RealmToday
//
//  Created by lottak_mac2 on 16/8/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "TodayCalendarModel.h"
#import "NSObject+data.h"
#import "MJExtension.h"
#import "TodayTableViewCell.h"

@interface TodayViewController () <NCWidgetProviding,UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;//表格视图
    UIButton *_addBtn;
    NSMutableArray<TodayCalendarModel*> *_calendarArr;//日程数组
}
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _calendarArr = [@[] mutableCopy];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"TodayTableViewCell" bundle:nil] forCellReuseIdentifier:@"TodayTableViewCell"];
    _tableView.separatorColor = [UIColor whiteColor];
    _tableView.tableFooterView = [UIView new];
    _addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_addBtn setTitle:@"无日程，去添加" forState:UIControlStateNormal];
    [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addBtn addTarget:self action:@selector(addCanaleClicked:) forControlEvents:UIControlEventTouchUpInside];
    _addBtn.frame = CGRectMake(0, 0, self.view.bounds.size.width, 180);
    [_tableView addSubview:_addBtn];
    NSUserDefaults *sharedDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.lottak.bangbang"];
    _calendarArr = [TodayCalendarModel mj_objectArrayWithKeyValuesArray:[sharedDefault objectForKey:@"GroupTodayInfo"]];
    if(_calendarArr.count == 0) {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 3 * 60);
        _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 3 * 60);
        _addBtn.hidden = NO;
    } else {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, _calendarArr.count * 60  <= 180 ? _calendarArr.count * 60 : 180);
        _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _calendarArr.count * 60  <= 180 ? _calendarArr.count * 60 : 180);
        _addBtn.hidden = YES;
    }
    [self.view addSubview:_tableView];
    // Do any additional setup after loading the view from its nib.
}
- (void)addCanaleClicked:(UIButton*)btn {
    //跳转到帮帮项目 添加日程
    [self.extensionContext openURL:[NSURL URLWithString:@"BangBang://addCalendar//"] completionHandler:nil];
}
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _calendarArr.count ?: 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(_calendarArr.count == 0)
        return [UITableViewCell new];
    TodayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TodayTableViewCell" forIndexPath:indexPath];
    cell.data = _calendarArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //跳转到帮帮项目 查看日程详情
    [self.extensionContext openURL:[NSURL URLWithString:[NSString stringWithFormat:@"BangBang://openCalendar//%lld",_calendarArr[indexPath.row].id]] completionHandler:nil];
}
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSUserDefaults *sharedDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.lottak.bangbang"];
    _calendarArr = [TodayCalendarModel mj_objectArrayWithKeyValuesArray:[sharedDefault objectForKey:@"GroupTodayInfo"]];
    if(_calendarArr.count == 0) {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, 3 * 60);
        _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 3 * 60);
        _addBtn.hidden = NO;
    } else {
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, _calendarArr.count * 60 <= 180 ? _calendarArr.count * 60 : 180);
        _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _calendarArr.count * 60 <= 180 ? _calendarArr.count * 60 : 180);
        _addBtn.hidden = YES;
    }
    [_tableView reloadData];
    completionHandler(NCUpdateResultNewData);
}

@end
