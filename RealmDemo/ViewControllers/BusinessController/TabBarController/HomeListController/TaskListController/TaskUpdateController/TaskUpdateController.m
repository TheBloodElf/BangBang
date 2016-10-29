//
//  TaskUpdateController.m
//  RealmDemo
//
//  Created by Mac on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskUpdateController.h"
#import "TaskTitleCell.h"
#import "TaskDetailCell.h"
#import "TaskFinishCell.h"
#import "TaskInchargeCell.h"
#import "TaskMemberCell.h"
#import "AddRemindCell.h"
#import "TaskRemindCell.h"

#import "UserManager.h"
#import "UserHttp.h"
#import "SelectDateController.h"
#import "SingleSelectController.h"
#import "MuliteSelectController.h"

@interface TaskUpdateController ()<UITableViewDataSource,UITableViewDelegate,MuliteSelectDelegate,SingleSelectDelegate,TaskRemindCellDelegate,TaskTitleCellDelegate,TaskDetailCellDelegate> {
    UITableView *_tableView;//表格视图
    UserManager *_userManager;//用户管理器
    TaskModel *_taskModel;//任务模型
    NSMutableArray<NSDate*> *_alertDateArr;//提醒时间数组
    Employee *_incharge;//负责人
    NSMutableArray<Employee*> *_memberArr;//参与人数组
}

@end

@implementation TaskUpdateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务创建";
    _incharge = [Employee new];
    _alertDateArr = [@[] mutableCopy];
    _memberArr = [@[] mutableCopy];
    _userManager = [UserManager manager];
    //得到负责人
    if(![NSString isBlank:_taskModel.incharge]) {
        for (Employee *employee in [_userManager getEmployeeWithCompanyNo:_taskModel.company_no status:5]) {
            if([employee.employee_guid isEqualToString:_taskModel.incharge]) {
                _incharge = employee;
                break;
            }
        }
    }
    //得到参与人
    if(![NSString isBlank:_taskModel.members]) {
        for (NSString *string in [_taskModel.members componentsSeparatedByString:@","]) {
            for (Employee *employee in [_userManager getEmployeeWithCompanyNo:_taskModel.company_no status:5]) {
                if([string isEqualToString:employee.employee_guid]) {
                    [_memberArr addObject:employee];
                    break;
                }
            }
        }
    }
    //得到提醒时间
    if(![NSString isBlank:_taskModel.alert_date_list]) {
        for (NSString *string in [_taskModel.alert_date_list componentsSeparatedByString:@","]) {
            [_alertDateArr addObject:[NSDate dateWithTimeIntervalSince1970:string.doubleValue / 1000]];
        }
    }
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[UINib nibWithNibName:@"TaskTitleCell" bundle:nil] forCellReuseIdentifier:@"TaskTitleCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskDetailCell" bundle:nil] forCellReuseIdentifier:@"TaskDetailCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskFinishCell" bundle:nil] forCellReuseIdentifier:@"TaskFinishCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskInchargeCell" bundle:nil] forCellReuseIdentifier:@"TaskInchargeCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskMemberCell" bundle:nil] forCellReuseIdentifier:@"TaskMemberCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"AddRemindCell" bundle:nil] forCellReuseIdentifier:@"AddRemindCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TaskRemindCell" bundle:nil] forCellReuseIdentifier:@"TaskRemindCell"];
    [self.view addSubview:_tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)dataDidChange {
    _taskModel = [self.data deepCopy];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor siginColor];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
- (void)rightClicked:(UIBarButtonItem*)item {
    [self.view endEditing:YES];
    if([NSString isBlank:_taskModel.task_name]) {
        [self.navigationController showMessageTips:@"请输入任务名称"];
        return;
    }
    if([NSString isBlank:_incharge.employee_guid]) {
        [self.navigationController showMessageTips:@"请选择负责人"];
        return;
    }
    if(_taskModel.enddate_utc < ([NSDate date].timeIntervalSince1970 * 1000)) {
        [self.navigationController showMessageTips:@"请选择正确的结束时间！"];
        return;
    }
    NSMutableArray<NSString*> *members = [@[] mutableCopy];
    for (Employee * employee in _memberArr) {
        [members addObject:employee.employee_guid];
    }
    _taskModel.members = [members componentsJoinedByString:@","];
    NSMutableArray<NSString*> *alerts = [@[] mutableCopy];
    for (NSDate *date in _alertDateArr) {
        [alerts addObject:@(date.timeIntervalSince1970 * 1000).stringValue];
    }
    _taskModel.incharge = _incharge.employee_guid;
    _taskModel.incharge_name = _incharge.real_name;
    _taskModel.alert_date_list = [alerts componentsJoinedByString:@","];
    _taskModel.begindate_utc = [NSDate date].timeIntervalSince1970 * 1000;
    [self.navigationController.view showLoadingTips:@""];
    NSMutableDictionary *dicc = [[_taskModel JSONDictionary] mutableCopy];
    [dicc setObject:_taskModel.descriptionStr forKey:@"description"];
    [UserHttp updateTask:dicc handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        _taskModel = [TaskModel new];
        [_taskModel mj_setKeyValues:data];
        _taskModel.descriptionStr = data[@"description"];
        [_userManager upadteTask:_taskModel];
        if(self.delegate && [self.delegate respondsToSelector:@selector(taskUpdate:)]) {
            [self.delegate taskUpdate:_taskModel];
        }
        [self.navigationController.view dismissTips];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1)
        return 88;
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 3)
        return 2;
    if(section == 5)
        return _alertDateArr.count + 1;
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskTitleCell" forIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskDetailCell" forIndexPath:indexPath];
    } else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskFinishCell" forIndexPath:indexPath];
    } else if (indexPath.section == 3) {
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TaskInchargeCell" forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TaskMemberCell" forIndexPath:indexPath];
        }
    } else if (indexPath.section == 4) {
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddRemindCell" forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TaskRemindCell" forIndexPath:indexPath];
        }
    }
    
    if(indexPath.section == 0) {//任务标题
        TaskTitleCell *title = (id)cell;
        title.data = _taskModel;
        title.delegate = self;
    } else if(indexPath.section == 1) {//任务详情
        TaskDetailCell *detail = (id)cell;
        detail.data = _taskModel;
        detail.delegate = self;
    } else if (indexPath.section == 2) {//结束时间
        cell.data = _taskModel;
    } else if (indexPath.section == 3) {
        if(indexPath.row == 0) {//负责人
            cell.data = _incharge;
        } else {//参与人
            cell.data = _memberArr;
        }
    } else {
        if(indexPath.row == 0) {//添加提醒
            
        } else {//提醒时间
            TaskRemindCell *remind = (id)cell;
            remind.data = _alertDateArr[indexPath.row - 1];
            remind.delegate = self;
        }
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
        
    } else if (indexPath.section == 2) {//结束时间
        SelectDateController *select = [SelectDateController new];
        select.selectDateBlock = ^(NSDate *date) {
            _taskModel.enddate_utc = date.timeIntervalSince1970 * 1000;
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        };
        select.datePickerMode = UIDatePickerModeDateAndTime;
        select.providesPresentationContextTransitionStyle = YES;
        select.definesPresentationContext = YES;
        select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:select animated:NO completion:nil];
    } else if (indexPath.section == 3) {
        if(indexPath.row == 0) {//负责人
            SingleSelectController *single = [SingleSelectController new];
            NSMutableArray *array = [@[] mutableCopy];
            //负责人还要去掉自己
            [array addObjectsFromArray:_memberArr];
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
            [array addObject:employee];
            single.outEmployees = array;
            single.delegate = self;
            [self.navigationController pushViewController:single animated:YES];
        } else {//参与人
            MuliteSelectController *mulite = [MuliteSelectController new];
            NSMutableArray *array = [@[] mutableCopy];
            if(_incharge.id != 0)
                array = [@[_incharge] mutableCopy];
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
            [array addObject:employee];
            mulite.outEmployees = array;
            mulite.selectedEmployees = _memberArr;
            mulite.delegate = self;
            [self.navigationController pushViewController:mulite animated:YES];
        }
    }  else {
        if(indexPath.row == 0) {//添加提醒时间
            SelectDateController *select = [SelectDateController new];
            select.selectDateBlock = ^(NSDate *date) {
                [_alertDateArr addObject:date];
                [_tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
            };
            select.datePickerMode = UIDatePickerModeDateAndTime;
            select.providesPresentationContextTransitionStyle = YES;
            select.definesPresentationContext = YES;
            select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:select animated:NO completion:nil];
        }
    }
}
#pragma mark -- TaskTitleCellDelegate
- (void)taskTitleLenghtOver {
    [self.view showMessageTips:@"任务名称不能大于30"];
}
#pragma mark -- TaskDetailCellDelegate
- (void)taskDetailLenghtOver {
    [self.view showMessageTips:@"任务描述不能大于500"];
}
#pragma mark -- TaskRemindCellDelegate
- (void)TaskRemindDeleteDate:(NSDate*)date {
    [_alertDateArr removeObject:date];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- SingleSelectDelegate
//单选回调
- (void)singleSelect:(Employee*)employee {
    _incharge = employee;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- MuliteSelectDelegate
//多选回调
- (void)muliteSelect:(NSMutableArray<Employee*>*)employeeArr {
    _memberArr = employeeArr;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
}
@end
