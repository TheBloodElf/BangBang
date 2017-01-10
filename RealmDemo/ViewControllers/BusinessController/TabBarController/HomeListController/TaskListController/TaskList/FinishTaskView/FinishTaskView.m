//
//  FinishTaskView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "FinishTaskView.h"
#import "TaskListCell.h"
#import "TaskModel.h"
#import "NoResultView.h"
#import "DotActivityIndicatorView.h"

@interface FinishTaskView  ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource> {
    UISearchBar *_searchBar;
    NSMutableArray<TaskModel*> *_currArr;
    UITableView *_tableView;
    NoResultView *_noDataView;
}


@end

@implementation FinishTaskView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currArr = [@[] mutableCopy];
        //创建搜索框
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"任务主题/姓名";
        _searchBar.tintColor = [UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1];
        [_searchBar setSearchBarBackgroundColor:[UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1]];
        _searchBar.returnKeyType = UIReturnKeySearch;
        for(UIView * view in [_searchBar.subviews[0] subviews]) {
            if([view isKindOfClass:[UITextField class]]) {
                [(UITextField*)view setEnablesReturnKeyAutomatically:NO];
                break;
            }
        }
        [self addSubview:_searchBar];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, MAIN_SCREEN_WIDTH, frame.size.height - 60) style:UITableViewStylePlain];
        DotActivityIndicatorView *loadView = [[DotActivityIndicatorView alloc] initWithFrame:_tableView.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = loadView;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerNib:[UINib nibWithNibName:@"TaskListCell" bundle:nil] forCellReuseIdentifier:@"TaskListCell"];
        [self addSubview:_tableView];
        _noDataView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    }
    return self;
}
- (void)dataDidChange {
    [self getCurrData];
}
- (void)getCurrData {
    NSMutableArray *array = [@[] mutableCopy];
    for (TaskModel *model in self.data) {
            if([NSString isBlank:_searchBar.text]) {
                [array addObject:model];
            } else {
                if([model.task_name rangeOfString:_searchBar.text].location != NSNotFound)
                    [array addObject:model];
                else if([model.incharge_name rangeOfString:_searchBar.text].location != NSNotFound)
                    [array addObject:model];
                else if([model.create_realname rangeOfString:_searchBar.text].location != NSNotFound)
                    [array addObject:model];
            }
    }
    _currArr = array;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_currArr.count == 0)
            _tableView.tableFooterView = _noDataView;
        else
            _tableView.tableFooterView = [UIView new];
        [_tableView reloadData];
    });
}
#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self endEditing:YES];
    [self getCurrData];
}
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskListCell" forIndexPath:indexPath];
    cell.data = _currArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.delegate && [self.delegate respondsToSelector:@selector(taskClicked:)]) {
        [self.delegate taskClicked:_currArr[indexPath.row]];
    }
}

@end
