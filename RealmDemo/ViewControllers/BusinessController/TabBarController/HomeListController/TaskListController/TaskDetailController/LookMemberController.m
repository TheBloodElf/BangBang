//
//  LookMemberController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "LookMemberController.h"
#import "UserManager.h"
#import "TaskModel.h"
#import "XAddrBookCell.h"

@interface LookMemberController ()<UITableViewDelegate,UITableViewDataSource> {
    UserManager *_userManager;
    TaskModel *_taskModel;
    NSMutableArray<Employee*> *_employeeArr;
    UITableView *_tableView;
}

@end

@implementation LookMemberController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"知悉人列表";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    _employeeArr = [@[] mutableCopy];
    NSArray *idArr = [_taskModel.members componentsSeparatedByString:@","];
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
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)dataDidChange {
    _taskModel = self.data;
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
}
@end
