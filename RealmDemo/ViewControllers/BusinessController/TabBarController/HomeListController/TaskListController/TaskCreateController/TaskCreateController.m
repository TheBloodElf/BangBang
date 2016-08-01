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

#import "UserManager.h"
#import "UserHttp.h"

@interface TaskCreateController ()<UITableViewDataSource,UITableViewDelegate> {
    UITableView *_tableView;//表格视图
    UserManager *_userManager;//用户管理器
    TaskModel *_taskModel;//任务模型
}

@end

@implementation TaskCreateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务创建";
    _userManager = [UserManager manager];
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    //初始化模型
    _taskModel = [TaskModel new];
    _taskModel.status = 1;
    _taskModel.createdby = employee.employee_guid;
    _taskModel.user_guid = _userManager.user.user_guid;
    _taskModel.avatar = _userManager.user.avatar;
    _taskModel.company_no = _userManager.user.currCompany.company_no;
    
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskTitleCell" bundle:nil] forCellReuseIdentifier:@"TaskTitleCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskDetailCell" bundle:nil] forCellReuseIdentifier:@"TaskDetailCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskFinishCell" bundle:nil] forCellReuseIdentifier:@"TaskFinishCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskInchargeCell" bundle:nil] forCellReuseIdentifier:@"TaskInchargeCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskMemberCell" bundle:nil] forCellReuseIdentifier:@"TaskMemberCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskAttenmentCell" bundle:nil] forCellReuseIdentifier:@"TaskAttenmentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"AddAttenmentCell" bundle:nil] forCellReuseIdentifier:@"AddAttenmentCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"AddRemindCell" bundle:nil] forCellReuseIdentifier:@"AddRemindCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskRemindCell" bundle:nil] forCellReuseIdentifier:@"TaskRemindCell"];
    [self.view addSubview:_tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)rightClicked:(UIBarButtonItem*)item {
    
}
#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20.F;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
