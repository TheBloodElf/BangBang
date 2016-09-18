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

@interface TaskCreateController ()<UITableViewDataSource,UITableViewDelegate,MuliteSelectDelegate,SingleSelectDelegate,TaskRemindCellDelegate,SelectImageDelegate,TaskAttenmentDelegate> {
    UITableView *_tableView;//表格视图
    UserManager *_userManager;//用户管理器
    TaskModel *_taskModel;//任务模型
    NSMutableArray<UIImage*> *_attanmentArr;//附件数组
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
    _attanmentArr = [@[] mutableCopy];
    _incharge = [Employee new];
    _alertDateArr = [@[] mutableCopy];
    _memberArr = [@[] mutableCopy];
    _fileManager = [FileManager shareManager];
    
    _userManager = [UserManager manager];
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    //初始化模型 看看有没有草稿
    NSMutableArray<TaskDraftModel*> *taskDraftModelArr = [_userManager getTaskDraftArr:_userManager.user.currCompany.company_no];
    if(taskDraftModelArr.count) {
        TaskDraftModel *model = taskDraftModelArr.firstObject;
        _taskModel = [[TaskModel alloc] initWithJSONDictionary:model.JSONDictionary];
        NSMutableArray *imageArr = [@[] mutableCopy];
        for (NSString *str in [model.attachmentArr componentsSeparatedByString:@","]) {
            if(![_fileManager fileIsExit:str]) continue;
            UIImage *image = [UIImage imageWithContentsOfFile:[_fileManager fileStr:str]];
            [imageArr addObject:image];
        }
        _attanmentArr = imageArr;
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
    //按钮是否能够被点击
    RACSignal *nameSignal = RACObserve(_taskModel, task_name);
    RACSignal *inchargeSignal = RACObserve(_taskModel, incharge_name);
    RAC(self.navigationItem.rightBarButtonItem,enabled) = [RACSignal combineLatest:@[nameSignal,inchargeSignal] reduce:^(NSString *task_name,NSString *incharge_name){
        if([NSString isBlank:task_name])
            return @(NO);
        if([NSString isBlank:incharge_name])
            return @(NO);
        return @(YES);
    }];
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
        TaskDraftModel *model = [[TaskDraftModel alloc] initWithJSONDictionary:_taskModel.JSONDictionary];
        NSMutableArray *imageFileArr = [@[] mutableCopy];
        for (UIImage *image in _attanmentArr) {
            NSString *imageName = @([NSDate date].timeIntervalSince1970 * 1000).stringValue;
            [imageFileArr addObject:imageName];
            [_fileManager writeData:[image dataInNoSacleLimitBytes:MaXPicSize] name:imageName];
        }
        model.attachmentArr = [imageFileArr componentsJoinedByString:@","];
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
    _taskModel.alert_date_list = [alerts componentsJoinedByString:@","];
    _taskModel.begindate_utc = [NSDate date].timeIntervalSince1970 * 1000;
    _taskModel.attachment_count = _attanmentArr.count;
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
                    TaskDraftModel *model = [[TaskDraftModel alloc] initWithJSONDictionary:_taskModel.JSONDictionary];
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
            return ;
        }
        _taskModel = [[TaskModel alloc] initWithJSONDictionary:data];
        _taskModel.descriptionStr = data[@"description"];
        [_userManager addTask:_taskModel];
        [self uploadAttanment];
    }];
}
//上传任务附件
- (void)uploadAttanment {
    if(_attanmantIndex == _attanmentArr.count) {
        [self.navigationController.view dismissTips];
        [self.navigationController.view showSuccessTips:@"创建成功"];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [UserHttp uploadAttachment:_userManager.user.user_guid taskId:_taskModel.id doc:_attanmentArr[_attanmantIndex] handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view dismissTips];
                [self.navigationController.view showFailureTips:@"有图片上传失败，请去任务详情继续上传"];
                return ;
            }
            _attanmantIndex ++;
            [self uploadAttanment];
        }];
    }
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
        return _attanmentArr.count + 1;
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
        cell.data = _taskModel;
    } else if(indexPath.section == 1) {//任务详情
        cell.data = _taskModel;
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
            cell.data = _attanmentArr[indexPath.row - 1];
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
    } else if(indexPath.section == 4) {//附件
        if(indexPath.row == 0) {
            SelectImageController *select = [SelectImageController new];
            select.maxSelect = 9 - _attanmentArr.count;
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
#pragma mark -- TaskRemindCellDelegate
- (void)TaskRemindDeleteDate:(NSDate*)date {
    [_alertDateArr removeObject:date];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- TaskAttenmentDelegate
- (void)TaskAttenmentDelete:(UIImage*)photo {
    [_attanmentArr removeObject:photo];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- SelectImageDelegate
- (void)selectImageFinish:(NSMutableArray<Photo*>*)photoArr {
    for (Photo *photo in photoArr) {
        [_attanmentArr addObject:photo.oiginalImage];
    }
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- SingleSelectDelegate
//单选回调
- (void)singleSelect:(Employee*)employee {
    _incharge = employee;
    _taskModel.incharge = _incharge.employee_guid;
    _taskModel.incharge_name = _incharge.real_name;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- MuliteSelectDelegate
//多选回调
- (void)muliteSelect:(NSMutableArray<Employee*>*)employeeArr {
    _memberArr = employeeArr;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
}
@end
