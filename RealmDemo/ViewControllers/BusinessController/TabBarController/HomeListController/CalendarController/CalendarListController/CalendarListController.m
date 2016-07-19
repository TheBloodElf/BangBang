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

@interface CalendarListController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource> {
    UITableView *_tableView;//表格视图
    UserManager *_userManager;//用户管理器
    UISearchBar *_searchBar;//搜索控件
    UIView *_noDataView;//没有数据的视图
    NSMutableDictionary<NSDate*,NSMutableArray<Calendar*>*> *_dataDic;//展示数据的字典
}

@end

@implementation CalendarListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"事务列表";
    _userManager = [UserManager manager];
    _dataDic = [@{} mutableCopy];
    //创建搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, MAIN_SCREEN_WIDTH, 55)];
    _searchBar.placeholder = @"搜索日程";
    [self.view addSubview:_searchBar];
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64 - 55) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[UINib nibWithNibName:@"CalenderEventTableViewCell" bundle:nil] forCellReuseIdentifier:@"CalenderEventTableViewCell"];
    [self.view addSubview:_tableView];
    [self searchTextFromLoc];
    [_tableView reloadData];
}
- (void)searchTextFromLoc {
    //这里需要把日程全部填充进来，有点难度
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

@end
