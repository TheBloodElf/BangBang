//
//  TaskCreateController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskCreateController.h"
#import "TaskTitleCell.h"
#import "TaskDetailCell.h"
#import "TaskFinishCell.h"
#import "TaskInchargeCell.h"
#import "TaskMemberCell.h"
#import "TaskAttenmentCell.h"
#import "AddAttenmentCell.h"
#import "AddRemindCell.h"
#import "TaskRemindCell.h"

@interface TaskCreateController () {
    UITableView *_tableView;
}

@end

@implementation TaskCreateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务创建";
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    // Do any additional setup after loading the view.
}

@end
