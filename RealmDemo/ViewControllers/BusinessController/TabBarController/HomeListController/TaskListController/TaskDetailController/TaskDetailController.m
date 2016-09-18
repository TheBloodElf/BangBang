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
#import "TaskDiscussSelectPersonController.h"

@interface TaskDetailController ()<TaskDetailDelegate,TaskFileDelegate,SelectImageDelegate,UIDocumentInteractionControllerDelegate,TaskDiscussDelegate,TaskDiscussSelectPersonDelegate> {
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
    
    [self.createAvater zy_cornerRadiusRoundingRect];
    [self.createAvater sd_setImageWithURL:[NSURL URLWithString:_taskModel.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.createName.text = _taskModel.create_realname;
    Employee *employee = [_userManager getEmployeeWithGuid:_taskModel.user_guid companyNo:_taskModel.company_no];
    self.createDepar.text = employee.departments;
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:_taskModel.createdon_utc / 1000];
    self.createTime.text = [NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",createDate.year,createDate.month,createDate.day,createDate.hour,createDate.minute];
    self.taskTitle.text = _taskModel.task_name;
    
    self.bottomScrollView.contentSize = CGSizeMake(3 * MAIN_SCREEN_WIDTH, self.bottomScrollView.frame.size.height);
    _taskDetailView = [[TaskDetailView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 150 - 64)];
    _taskDetailView.delegate = self;
    [self.bottomScrollView addSubview:_taskDetailView];
    _taskDiscussView = [[TaskDiscussView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 150 - 64)];
    _taskDiscussView.data = _taskModel;
    _taskDiscussView.delegate = self;
    [self.bottomScrollView addSubview:_taskDiscussView];
    _taskFileView = [[TaskFileView alloc] initWithFrame:CGRectMake(2 *MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 150 - 64)];
    _taskFileView.delegate = self;
    _taskFileView.data = _taskModel;
    
    [self.bottomScrollView addSubview:_taskFileView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTaskInfo:) name:@"ReloadTaskInfo" object:nil];
    //获取任务详情  因为这里要控制红点的显示 不然都放到详情VIEW处理了
    [UserHttp getTaskInfo:_taskModel.id handler:^(id data, MError *error) {
        [self dismissTips];
        if(error) {
            [self showFailureTips:error.statsMsg];
            return ;
        }
        _taskModel = [[TaskModel alloc] initWithJSONDictionary:data];
        _taskModel.descriptionStr = data[@"description"];
        [_userManager upadteTask:_taskModel];
        _taskDetailView.data = _taskModel;
        //是否有消息 讨论显示小红点
        Employee *employeeOfMe = [[UserManager manager] getEmployeeWithGuid:[UserManager manager].user.user_guid companyNo:_taskModel.company_no];
        if([employeeOfMe.employee_guid isEqualToString:_taskModel.createdby]) {//是不是创建者
            if(_taskModel.creator_unread_commentcount) {
                [[self.view viewWithTag:1001] addHotView:HOTVIEW_ALIGNMENT_TOP_RIGHT];
            }
        }
        if([employeeOfMe.employee_guid isEqualToString:_taskModel.incharge]) {//是不是负责人
            if(_taskModel.incharge_unread_commentcount) {
                [[self.view viewWithTag:1001] addHotView:HOTVIEW_ALIGNMENT_TOP_RIGHT];
            }
        }
    }];
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
//任务有更新
- (void)reloadTaskInfo:(NSNotification*)noti {
    PushMessage *message = noti.object;
    if(message.target_id.intValue == _taskModel.id) {
        _taskFileView.data = _taskModel;
        _taskDiscussView.data = _taskModel;
        //获取任务详情
        [UserHttp getTaskInfo:_taskModel.id handler:^(id data, MError *error) {
            [self dismissTips];
            if(error) {
                [self showFailureTips:error.statsMsg];
                return ;
            }
            _taskModel = [[TaskModel alloc] initWithJSONDictionary:data];
            _taskModel.descriptionStr = data[@"description"];
            [_userManager upadteTask:_taskModel];
            _taskDetailView.data = _taskModel;
            //是否有消息 讨论显示小红点 如果当前在讨论界面 直接返回 因为自己发的消息肯定没有未读数量
            if(_bottomScrollView.contentOffset.x == _bottomScrollView.frame.size.width) return;
            Employee *employeeOfMe = [[UserManager manager] getEmployeeWithGuid:[UserManager manager].user.user_guid companyNo:_taskModel.company_no];
            if([employeeOfMe.employee_guid isEqualToString:_taskModel.createdby]) {//是不是创建者
                if(_taskModel.creator_unread_commentcount) {
                    [[self.view viewWithTag:1001] addHotView:HOTVIEW_ALIGNMENT_TOP_RIGHT];
                }
            }
            if([employeeOfMe.employee_guid isEqualToString:_taskModel.incharge]) {//是不是负责人
                if(_taskModel.incharge_unread_commentcount) {
                    [[self.view viewWithTag:1001] addHotView:HOTVIEW_ALIGNMENT_TOP_RIGHT];
                }
            }
        }];
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
    if(sender.tag == 1001) {//点击的是评论 就消除小红点
        [sender removeHotView];
        Employee *employeeOfMe = [[UserManager manager] getEmployeeWithGuid:[UserManager manager].user.user_guid companyNo:_taskModel.company_no];
        //更新评论状态  如果本来就没有数量就不管 不是负责人/创建者也不用管
        BOOL needUpdate = NO;
        //如果是负责人
        if([_taskModel.incharge isEqualToString:employeeOfMe.employee_guid]) {
            if(_taskModel.incharge_unread_commentcount == 0) return;
            needUpdate = YES;
        }
        //如果是创建者
        if([_taskModel.createdby isEqualToString:employeeOfMe.employee_guid]) {
            if(_taskModel.creator_unread_commentcount == 0) return;
            needUpdate = YES;
        }
        if(!needUpdate) return;
        [UserHttp updateTaskCommentStatus:_taskModel.id employeeGuid:employeeOfMe.employee_guid handler:^(id data, MError *error) {
            if(error) {
                [self showFailureTips:error.statsMsg];
                return ;
            }
            //如果是负责人
            if([_taskModel.incharge isEqualToString:employeeOfMe.employee_guid]) {
                _taskModel.incharge_unread_commentcount = 0;
                [_userManager upadteTask:_taskModel];
            }
            //如果是创建者
            if([_taskModel.createdby isEqualToString:employeeOfMe.employee_guid]) {
                _taskModel.creator_unread_commentcount = 0;
                [_userManager upadteTask:_taskModel];
            }
        }];
    }
}
#pragma mark -- TaskDiscussSelectPersonDelegate
- (void)taskDiscussSelectPerson:(Employee*)employee {
    [_taskDiscussView setEmployee:employee];
}
- (void)taskDiscussSelectCancle {
    [_taskDiscussView selectCancle];
}
#pragma makr -- TaskDiscussDelegate
- (void)taskDiscussSelectPersion{
    TaskDiscussSelectPersonController *taskSelect = [TaskDiscussSelectPersonController new];
    taskSelect.data = _taskModel;
    taskSelect.delegate = self;
    [self.navigationController pushViewController:taskSelect animated:YES];
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
        _taskModel = [task deepCopy];
        _taskModel.status = 2;
        _taskDetailView.data = _taskModel;
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
            _taskModel = [task deepCopy];
            _taskModel.status = 8;
            _taskDetailView.data = _taskModel;
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
            _taskModel = [task deepCopy];
            _taskModel.status = 6;
            _taskDetailView.data = _taskModel;
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
            _taskModel = [task deepCopy];
            _taskModel.status = 7;
            _taskDetailView.data = _taskModel;
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
            _taskModel = [task deepCopy];
            _taskModel.status = 4;
            _taskDetailView.data = _taskModel;
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
    NSMutableArray *arary = [@[] mutableCopy];
    for (Photo * photo in photoArr) {
        [arary addObject:photo.oiginalImage];
    }
    _attanmentArr = arary;
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
