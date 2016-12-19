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
#import "SelectDateController.h"
#import "SingleSelectController.h"
#import "MuliteSelectController.h"
#import "SelectImageController.h"
#import "FileManager.h"

@interface TaskCreateController ()<UITableViewDataSource,UITableViewDelegate,MuliteSelectDelegate,SingleSelectDelegate,TaskRemindCellDelegate,SelectImageDelegate,TaskAttenmentDelegate,TaskTitleCellDelegate,TaskDetailCellDelegate> {
    UITableView *_tableView;//表格视图
    UserManager *_userManager;//用户管理器
    TaskModel *_taskModel;//任务模型
    UIImage *_taskAttanment;//附件数组
    FileManager *_fileManager;//文件管理去 用来存取本地文件
    int _attanmantIndex;//任务上传数量下标
    NSMutableArray<NSDate*> *_alertDateArr;//提醒时间数组
    Employee *_incharge;//负责人
    NSMutableArray<Employee*> *_memberArr;//参与人数组
}

@end

@implementation TaskCreateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务创建";
    _incharge = [Employee new];
    _alertDateArr = [@[] mutableCopy];
    _memberArr = [@[] mutableCopy];
    _fileManager = [FileManager shareManager];
    _userManager = [UserManager manager];
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    //初始化模型 看看有没有草稿
    NSMutableArray<TaskDraftModel*> *taskDraftModelArr = [_userManager getTaskDraftArr:_userManager.user.currCompany.company_no];
    if(taskDraftModelArr.count) {//草稿模型赋给当前任务模型
        TaskDraftModel *model = taskDraftModelArr.firstObject;
        _taskModel = [TaskModel new];
        _taskModel.task_name = model.task_name;
        _taskModel.descriptionStr = model.descriptionStr;
        _taskModel.company_no = model.company_no;
        _taskModel.enddate_utc = model.enddate_utc;
        _taskModel.user_guid = model.user_guid;
        _taskModel.avatar = model.avatar;
        _taskModel.createdby = model.createdby;
        _taskModel.status = model.status;
        //得到附件
        if(![NSString isBlank:model.attachmentArr]) {
            if([_fileManager fileIsExit:model.attachmentArr]) {
                _taskAttanment = [UIImage imageWithContentsOfFile:[_fileManager fileStr:model.attachmentArr]];
            }
        }
        //得到负责人
        if(![NSString isBlank:model.incharge]) {
            for (Employee *employee in [_userManager getEmployeeWithCompanyNo:model.company_no status:5]) {
                if([employee.employee_guid isEqualToString:model.incharge]) {
                    _incharge = employee;
                    break;
                }
            }
        }
        //得到参与人
        if(![NSString isBlank:model.members]) {
            for (NSString *string in [model.members componentsSeparatedByString:@","]) {
               for (Employee *employee in [_userManager getEmployeeWithCompanyNo:model.company_no status:5]) {
                   if([string isEqualToString:employee.employee_guid]) {
                       [_memberArr addObject:employee];
                       break;
                   }
               }
            }
        }
        //得到提醒时间
        if(![NSString isBlank:model.alert_date_list]) {
            for (NSString *string in [model.alert_date_list componentsSeparatedByString:@","]) {
                [_alertDateArr addObject:[NSDate dateWithTimeIntervalSince1970:string.doubleValue / 1000]];
            }
        }
    } else {
        _taskModel = [TaskModel new];
        _taskModel.status = 1;
        _taskModel.id = [NSDate date].timeIntervalSince1970;
        _taskModel.createdby = employee.employee_guid;
        _taskModel.enddate_utc = [[NSDate date] timeIntervalSince1970] * 1000;
        _taskModel.user_guid = _userManager.user.user_guid;
        _taskModel.avatar = _userManager.user.avatar;
        _taskModel.company_no = _userManager.user.currCompany.company_no;
        _taskModel.descriptionStr = @"";
    }
    
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(leftClicked:)];
    // Do any additional setup after loading the view.
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
- (void)leftClicked:(UIBarButtonItem*)item {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"保存为草稿?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TaskDraftModel *model = [TaskDraftModel new];
        model.task_name = _taskModel.task_name;
        model.company_no = _taskModel.company_no;
        model.enddate_utc = _taskModel.enddate_utc;
        model.descriptionStr = _taskModel.descriptionStr;
        model.user_guid = _taskModel.user_guid;
        model.avatar = _taskModel.avatar;
        model.createdby = _taskModel.createdby;
        model.status = _taskModel.status;
        //得到负责人
        model.incharge = _incharge.employee_guid;
        //得到参与人
        NSMutableArray<NSString*> *members = [@[] mutableCopy];
        for (Employee * employee in _memberArr) {
            [members addObject:employee.employee_guid];
        }
        model.members = [members componentsJoinedByString:@","];
        //得到提醒时间
        NSMutableArray<NSString*> *alerts = [@[] mutableCopy];
        for (NSDate *date in _alertDateArr) {
            [alerts addObject:@(date.timeIntervalSince1970 * 1000).stringValue];
        }
        model.alert_date_list = [alerts componentsJoinedByString:@","];
        //得到附件
        if(_taskAttanment) {
            NSString *imageName = @([NSDate date].timeIntervalSince1970 * 1000).stringValue;
            [_fileManager writeData:[_taskAttanment dataInNoSacleLimitBytes:MaXPicSize] name:imageName];
            model.attachmentArr = imageName;
        }
        //这样来触发数据表回调 因为id是0
        [_userManager deleteTaskDraft:model];
        [_userManager updateTaskDraft:model companyNo:_userManager.user.currCompany.company_no];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"不保存" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray<TaskDraftModel*> *array = [_userManager getTaskDraftArr:_userManager.user.currCompany.company_no];
        for (TaskDraftModel *model in array) {
            [_userManager deleteTaskDraft:model];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertVC addAction:cancleAction];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
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
    _taskModel.attachment_count = _taskAttanment?1:0;
    //提交任务数据后上传任务附件
    _attanmantIndex = 0;
    [self.navigationController.view showLoadingTips:@""];
    NSMutableDictionary *dicc = [[_taskModel JSONDictionary] mutableCopy];
    [dicc setObject:_taskModel.descriptionStr forKey:@"description"];
    [UserHttp createTask:dicc handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view dismissTips];
            if(error.statsCode == -1009) {//没有网络可以保存到本地
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"网络不可用，保存为草稿?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    TaskDraftModel *model = [TaskDraftModel new];
                    model.task_name = _taskModel.task_name;
                    model.company_no = _taskModel.company_no;
                    model.enddate_utc = _taskModel.enddate_utc;
                    model.descriptionStr = _taskModel.descriptionStr;
                    model.user_guid = _taskModel.user_guid;
                    model.avatar = _taskModel.avatar;
                    model.createdby = _taskModel.createdby;
                    model.status = _taskModel.status;
                    //得到负责人
                    model.incharge = _taskModel.incharge;
                    //得到参与人
                    model.members = _taskModel.members;
                    //得到提醒时间
                    model.alert_date_list = _taskModel.alert_date_list;
                    //得到附件
                    if(_taskAttanment) {
                        NSString *imageName = @([NSDate date].timeIntervalSince1970 * 1000).stringValue;
                        [_fileManager writeData:[_taskAttanment dataInNoSacleLimitBytes:MaXPicSize] name:imageName];
                        model.attachmentArr = imageName;
                    }
                    //这样来触发数据表回调 因为id是0
                    [_userManager deleteTaskDraft:model];
                    [_userManager updateTaskDraft:model companyNo:_userManager.user.currCompany.company_no];
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"不保存" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    NSMutableArray<TaskDraftModel*> *array = [_userManager getTaskDraftArr:_userManager.user.currCompany.company_no];
                    for (TaskDraftModel *model in array) {
                        [_userManager deleteTaskDraft:model];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alertVC addAction:cancleAction];
                [alertVC addAction:okAction];
                [self presentViewController:alertVC animated:YES completion:nil];
                return ;
            }
            [self.navigationController.view showMessageTips:error.statsMsg];
            return ;
        }
        _taskModel = [TaskModel new];
        [_taskModel mj_setKeyValues:data];
        _taskModel.descriptionStr = data[@"description"];
        [_userManager addTask:_taskModel];
        //有附件就上传附件
        if(_taskAttanment) {
            [UserHttp uploadAttachment:_userManager.user.user_guid taskId:_taskModel.id doc:_taskAttanment handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController.view dismissTips];
                    [self.navigationController.view showFailureTips:@"有图片上传失败，请去任务详情继续上传"];
                    return ;
                }
                NSMutableArray<TaskDraftModel*> *array = [_userManager getTaskDraftArr:_userManager.user.currCompany.company_no];
                for (TaskDraftModel *model in array) {
                    [_userManager deleteTaskDraft:model];
                }
                [self.navigationController.view dismissTips];
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            NSMutableArray<TaskDraftModel*> *array = [_userManager getTaskDraftArr:_userManager.user.currCompany.company_no];
            for (TaskDraftModel *model in array) {
                [_userManager deleteTaskDraft:model];
            }
            [self.navigationController.view dismissTips];
            [self.navigationController popViewControllerAnimated:YES];
        }
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
    if(section == 4)
        return _taskAttanment?2:1;
    if(section == 5)
        return _alertDateArr.count + 1;
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
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
            cell = [tableView dequeueReusableCellWithIdentifier:@"AddAttenmentCell" forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TaskAttenmentCell" forIndexPath:indexPath];
        }
    } else if (indexPath.section == 5) {
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
    } else if (indexPath.section == 4) {
        if(indexPath.row == 0) {//添加附件
            
        } else {//附件列表
            TaskAttenmentCell *task = (id)cell;
            cell.data = _taskAttanment;
            task.delegate = self;
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
        select.needShowDate = [NSDate dateWithTimeIntervalSince1970:_taskModel.enddate_utc / 1000];
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
            single.companyNo = _userManager.user.currCompany.company_no;
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
            mulite.companyNo = _userManager.user.currCompany.company_no;
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
    } else if(indexPath.section == 4) {//附件
        if(indexPath.row == 0) {
            SelectImageController *select = [SelectImageController new];
            select.maxSelect = 1;
            select.delegate = self;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:select] animated:YES completion:nil];
        }
    } else {
        if(indexPath.row == 0) {//添加提醒时间
            SelectDateController *select = [SelectDateController new];
            select.selectDateBlock = ^(NSDate *date) {
                [_alertDateArr addObject:date];
                [_tableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationNone];
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
#pragma mark -- TaskAttenmentDelegate
- (void)TaskAttenmentDelete:(UIImage*)photo {
    _taskAttanment = nil;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- SelectImageDelegate
- (void)selectImageFinish:(NSMutableArray<Photo*>*)photoArr {
    _taskAttanment = photoArr.firstObject.oiginalImage;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
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
