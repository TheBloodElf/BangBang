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
#import "RYChatController.h"

@interface DiscussListViewController ()<UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *contentArr;
    UITableView *tableView;
}
@property(nonatomic,strong)UIView *empty;
@end

@implementation DiscussListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    contentArr = [@[] mutableCopy];
    self.title = @"讨论组";
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    [tableView registerNib:[UINib nibWithNibName:@"DiscussListCell" bundle:nil] forCellReuseIdentifier:@"DiscussListCell"];
    [self.view addSubview:tableView];
    [self.view addSubview:_empty];
    _empty.hidden = YES;
}

#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return contentArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)sender cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiscussListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DiscussListCell" forIndexPath:indexPath];
    cell.data = contentArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UserDiscuss *model = [contentArr objectAtIndex:indexPath.row];
    RYChatController *temp = [[RYChatController alloc]init];
    temp.targetId = model.discuss_id;
    temp.conversationType = ConversationType_DISCUSSION;
    temp.title = model.discuss_title;
    [self.navigationController pushViewController:temp animated:YES];
}
@end
