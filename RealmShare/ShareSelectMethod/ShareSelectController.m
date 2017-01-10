//
//  ShareSelectController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "ShareSelectController.h"
#import "UtikIesTool.h"
#import "SelectCompanyController.h"
@interface ShareSelectController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
}

@end

@implementation ShareSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"分享到帮帮";
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 250, 330)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(leftAction:)];
    // Do any additional setup after loading the view.
}
- (void)leftAction:(UIBarButtonItem*)item
{
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}
#pragma mark -- 
#pragma mark UITableViewDelegate
#pragma mark --
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    if(indexPath.row == 0) {
        cell.textLabel.text = @"动态";
    } else {
        cell.textLabel.text = @"会议";
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[SelectCompanyController new] animated:YES];
    
}
@end
