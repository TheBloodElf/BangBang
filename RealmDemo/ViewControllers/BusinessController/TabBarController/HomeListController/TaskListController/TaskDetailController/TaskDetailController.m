//
//  TaskDetailController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDetailController.h"
#import "TaskModel.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "TaskFileView.h"
#import "TaskDiscussView.h"
#import "TaskDetailView.h"

#import "SelectImageController.h"
#import "LookMemberController.h"
#import "InputTextController.h"

@interface TaskDetailController ()<TaskDetailDelegate,TaskFileDelegate,SelectImageDelegate,UIDocumentInteractionControllerDelegate> {
    TaskModel *_taskModel;//要展示的任务模型
    UserManager *_userManager;
    
    TaskDetailView *_taskDetailView;//任务详情
    TaskDiscussView *_taskDiscussView;//任务讨论
    TaskFileView *_taskFileView;//任务附件
    UIView *_lineView;//下面绿色的条
    
    NSMutableArray<UIImage*> *_attanmentArr;//附件数组
    int _attanmantIndex;//任务上传数量下标
}
@property (weak, nonatomic) IBOutlet UIImageView *createAvater;//创建人的头像
@property (weak, nonatomic) IBOutlet UILabel *createName;//创建人的名字
@property (weak, nonatomic) IBOutlet UILabel *createDepar;//创建人的部门
@property (weak, nonatomic) IBOutlet UILabel *createTime;//创建时间
@property (weak, nonatomic) IBOutlet UILabel *taskTitle;//任务标题
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;//下面的滚动视图

@end

@implementation TaskDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务详情";
    _attanmentArr = [@[] mutableCopy];
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    //初始化界面
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(2, 148, MAIN_SCREEN_WIDTH / 3 - 4, 2)];
    _lineView.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    [self.view addSubview:_lineView];
    
    self.createAvater.layer.cornerRadius = 21;
    self.createAvater.clipsToBounds = YES;
    [self.createAvater sd_setImageWithURL:[NSURL URLWithString:_taskModel.avatar] placeholderImage:[UIImage imageNamed:@""]];
    self.createName.text = _taskModel.create_realname;
    Employee *employee = [_userManager getEmployeeWithGuid:_taskModel.user_guid companyNo:_taskModel.company_no];
    self.createDepar.text = employee.departments;
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:_taskModel.createdon_utc / 1000];
    self.createTime.text = [NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",createDate.year,createDate.month,createDate.day,createDate.hour,createDate.minute];
    self.taskTitle.text = _taskModel.task_name;
    
    self.bottomScrollView.contentSize = CGSizeMake(3 * MAIN_SCREEN_WIDTH, self.bottomScrollView.frame.size.height);
    _taskDetailView = [[TaskDetailView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 150 - 64)];
    _taskDetailView.data = _taskModel;
    _taskDetailView.delegate = self;
    [self.bottomScrollView addSubview:_taskDetailView];
    _taskDiscussView = [[TaskDiscussView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 150 - 64)];
    _taskDiscussView.data = _taskModel;
    [self.bottomScrollView addSubview:_taskDiscussView];
    _taskFileView = [[TaskFileView alloc] initWithFrame:CGRectMake(2 *MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 150 - 64)];
    _taskFileView.delegate = self;
    _taskFileView.data = _taskModel;
    [self.bottomScrollView addSubview:_taskFileView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTaskInfo:) name:@"ReloadTaskInfo" object:nil];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
- (void)dataDidChange {
    _taskModel = [self.data deepCopy];
}
- (void)reloadTaskInfo:(NSNotification*)noti {
    PushMessage *message = noti.object;
    if(message.target_id.intValue == _taskModel.id) {
        _taskFileView.data = _taskModel;
        _taskDetailView.data = _taskModel;
        _taskDiscussView.data = _taskModel;
    }
}
//详情/讨论/附件被点击
- (IBAction)btnClicked:(UIButton*)sender {
    UIButton *btn = [self.view viewWithTag:1000];
    btn.selected = NO;
    UIButton *btn1 = [self.view viewWithTag:1001];
    btn1.selected = NO;
    UIButton *btn2 = [self.view viewWithTag:1002];
    btn2.selected = NO;
    sender.selected = YES;
    _lineView.center = CGPointMake((MAIN_SCREEN_WIDTH / 3.f) * (sender.tag - 1000) + MAIN_SCREEN_WIDTH / 6.f, _lineView.center.y);
    int index = sender.tag - 1000;
    [self.view endEditing:YES];
    [self.bottomScrollView setContentOffset:CGPointMake(index * MAIN_SCREEN_WIDTH, 0) animated:NO];
}
#pragma mark -- TaskDetailDelegate
//接收
- (void)acceptClicked:(UIButton*)btn task:(id)task{
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    [UserHttp updateTask:_taskModel.id status:2 comment:@"" updatedby:employee.employee_guid handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        _taskDetailView.data = _taskModel;
        _taskModel = [task deepCopy];
        _taskModel.status = 2;
        [_userManager upadteTask:_taskModel];
    }];
}
//终止
- (void)stopClicked:(UIButton*)btn task:(id)task{
    InputTextController *input = [InputTextController new];
    input.inputTextBlock = ^(NSString *content) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
        [UserHttp updateTask:_taskModel.id status:8 comment:content updatedby:employee.employee_guid handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            _taskDetailView.data = _taskModel;
            _taskModel = [task deepCopy];
            _taskModel.status = 8;
            [_userManager upadteTask:_taskModel];
        }];
    };
    input.providesPresentationContextTransitionStyle = YES;
    input.definesPresentationContext = YES;
    input.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:input animated:NO completion:nil];
}
//退回
- (void)returnClicked:(UIButton*)btn task:(id)task{
    InputTextController *input = [InputTextController new];
    input.inputTextBlock = ^(NSString *content) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
        [UserHttp updateTask:_taskModel.id status:6 comment:content updatedby:employee.employee_guid handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            _taskDetailView.data = _taskModel;
            _taskModel = [task deepCopy];
            _taskModel.status = 6;
            [_userManager upadteTask:_taskModel];
        }];
    };
    input.providesPresentationContextTransitionStyle = YES;
    input.definesPresentationContext = YES;
    input.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:input animated:NO completion:nil];
}
//通过
- (void)passClicked:(UIButton*)btn task:(id)task{
    InputTextController *input = [InputTextController new];
    input.inputTextBlock = ^(NSString *content) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
        [UserHttp updateTask:_taskModel.id status:7 comment:content updatedby:employee.employee_guid handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            _taskDetailView.data = _taskModel;
            _taskModel = [task deepCopy];
            _taskModel.status = 7;
            [_userManager upadteTask:_taskModel];
        }];
    };
    input.providesPresentationContextTransitionStyle = YES;
    input.definesPresentationContext = YES;
    input.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:input animated:NO completion:nil];
}
//提交
- (void)submitClicked:(UIButton*)btn task:(id)task{
    InputTextController *input = [InputTextController new];
    input.inputTextBlock = ^(NSString *content) {
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
        [UserHttp updateTask:_taskModel.id status:4 comment:content updatedby:employee.employee_guid handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            _taskDetailView.data = _taskModel;
            _taskModel = [task deepCopy];
            _taskModel.status = 4;
            [_userManager upadteTask:_taskModel];
        }];
    };
    input.providesPresentationContextTransitionStyle = YES;
    input.definesPresentationContext = YES;
    input.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:input animated:NO completion:nil];
}
//查看所有知悉人
- (void)lookMember {
    LookMemberController *look = [LookMemberController new];
    look.data = _taskModel;
    [self.navigationController pushViewController:look animated:YES];
}
#pragma mark -- TaskFileDelegate
- (void)uploadTaskFile {
    SelectImageController *select = [SelectImageController new];
    select.maxSelect = 9;
    select.delegate = self;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:select] animated:YES completion:nil];
}
//预览文件
- (void)lookTaskFile:(NSURL*)fileUrl {
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController
     interactionControllerWithURL:fileUrl];
    documentController.delegate = self;
    [documentController presentPreviewAnimated:YES];
}
- (UIViewController *) documentInteractionControllerViewControllerForPreview:
(UIDocumentInteractionController *) controller {
    return self;
}
#pragma mark -- SelectImageDelegate
- (void)selectImageFinish:(NSMutableArray<Photo*>*)photoArr {
    [_attanmentArr removeAllObjects];
    for (Photo * photo in photoArr) {
        [_attanmentArr addObject:photo.oiginalImage];
    }
    _attanmantIndex = 0;
    [self.navigationController.view showLoadingTips:@"上传附件..."];
    [self uploadAttanment];
}
//上传任务附件
- (void)uploadAttanment {
    if(_attanmantIndex == _attanmentArr.count) {
        [self.navigationController.view dismissTips];
        [self.navigationController.view showSuccessTips:@"上传成功"];
        _taskFileView.data = _taskModel;
    } else {
        [UserHttp uploadAttachment:_userManager.user.user_guid taskId:_taskModel.id doc:_attanmentArr[_attanmantIndex] handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view dismissTips];
                [self.navigationController.view showFailureTips:@"有图片上传失败，请重试"];
                return ;
            }
            _attanmantIndex ++;
            [self uploadAttanment];
        }];
    }
}

@end
