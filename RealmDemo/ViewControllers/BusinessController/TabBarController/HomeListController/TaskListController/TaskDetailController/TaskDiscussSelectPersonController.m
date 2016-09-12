//
//  TaskDiscussSelectPersonController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/9/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDiscussSelectPersonController.h"
#import "TaskModel.h"
#import "XAddrBookCell.h"

@interface TaskDiscussSelectPersonController ()<UITableViewDelegate,UITableViewDataSource> {
    UserManager *_userManager;
    TaskModel *_taskModel;
    NSMutableArray<Employee*> *_employeeArr;
    UITableView *_tableView;
}


@end

@implementation TaskDiscussSelectPersonController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择任务组员";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    _employeeArr = [@[] mutableCopy];
    NSMutableArray *idArr = [@[] mutableCopy];
    [idArr addObjectsFromArray:[_taskModel.members componentsSeparatedByString:@","]];
    [idArr addObject:_taskModel.incharge];
    [idArr addObject:_taskModel.createdby];
    //除去自己
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    [idArr removeObject:employee.employee_guid];
    NSArray *employeeArr = [_userManager getEmployeeWithCompanyNo:_taskModel.company_no status:5];
    for (NSString *guid in idArr) {
        for (Employee *employee in employeeArr) {
            if([guid isEqualToString:employee.employee_guid]) {
                [_employeeArr addObject:employee];
                break;
            }
        }
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"XAddrBookCell" bundle:nil] forCellReuseIdentifier:@"XAddrBookCell"];
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(leftAction:)];
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)dataDidChange {
    _taskModel = self.data;
}
- (void)leftAction:(UIBarButtonItem*)item {
    if(self.delegate && [self.delegate respondsToSelector:@selector(taskDiscussSelectCancle)]) {
        [self.delegate taskDiscussSelectCancle];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _employeeArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XAddrBookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XAddrBookCell" forIndexPath:indexPath];
    Employee * employee = _employeeArr[indexPath.row];
    cell.data = employee;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.delegate && [self.delegate respondsToSelector:@selector(taskDiscussSelectPerson:)]) {
        [self.delegate taskDiscussSelectPerson:_employeeArr[indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
@end
