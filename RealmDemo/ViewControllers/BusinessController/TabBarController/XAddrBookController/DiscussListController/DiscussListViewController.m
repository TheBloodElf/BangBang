//
//  DiscussListViewController.m
//  BangBang
//
//  Created by PC-002 on 16/1/15.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "DiscussListViewController.h"
#import "UserDiscuss.h"
#import "DiscussListCell.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "RYChatController.h"
#import "NoResultView.h"

@interface DiscussListViewController ()<UITableViewDelegate,UITableViewDataSource,RBQFetchedResultsControllerDelegate> {
    NSMutableArray<UserDiscuss*> *_userDiscussArr;//讨论组数组
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userDiscussFetchedResultsController;//讨论组数据监听
    UITableView *_tableView;//表格视图
    NoResultView *_noDataView;//没有数据时展示的视图
}
@end

@implementation DiscussListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"讨论组";
    _userManager = [UserManager manager];
    _userDiscussArr = [_userManager getUserDiscussArr];
    _userDiscussFetchedResultsController = [_userManager createUserDiscusFetchedResultsController];
    _userDiscussFetchedResultsController.delegate = self;
    
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _noDataView = [[NoResultView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    if(_userDiscussArr.count == 0)
        _tableView.tableFooterView = _noDataView;
    else
        _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"DiscussListCell" bundle:nil] forCellReuseIdentifier:@"DiscussListCell"];
    [self.view addSubview:_tableView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightClicked:)];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    [self.navigationController.view showLoadingTips:@"同步讨论组..."];
    [UserHttp getUserDiscuss:_userManager.user.user_no handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray<UserDiscuss*> *array = [@[] mutableCopy];
        for (NSDictionary * dic in data) {
            UserDiscuss *discuss = [UserDiscuss new];
            [discuss mj_setKeyValues:dic];
            [array addObject:discuss];
        }
        [_userManager updateUserDiscussArr:array];
        [self.navigationController.view showSuccessTips:@"同步成功"];
    }];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    _userDiscussArr = [_userManager getUserDiscussArr];
    if(_userDiscussArr.count == 0)
        _tableView.tableFooterView = _noDataView;
    else
        _tableView.tableFooterView = [UIView new];
    [_tableView reloadData];
}
#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _userDiscussArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiscussListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscussListCell" forIndexPath:indexPath];
    cell.data = _userDiscussArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserDiscuss *model = [_userDiscussArr objectAtIndex:indexPath.row];
    RYChatController *temp = [[RYChatController alloc]init];
    temp.targetId = model.discuss_id;
    temp.companyNo = model.companyNo;
    temp.conversationType = ConversationType_DISCUSSION;
    temp.title = model.discuss_title;
    [self.navigationController pushViewController:temp animated:YES];
}
@end
