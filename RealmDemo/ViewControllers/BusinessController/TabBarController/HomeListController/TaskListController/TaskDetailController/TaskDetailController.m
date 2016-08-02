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

@interface TaskDetailController () {
    TaskModel *_taskModel;//要展示的任务模型
    UserManager *_userManager;
    
    TaskDetailView *_taskDetailView;//任务详情
    TaskDiscussView *_taskDiscussView;//任务讨论
    TaskFileView *_taskFileView;//任务附件
}
@property (weak, nonatomic) IBOutlet UIImageView *createAvater;//创建人的头像
@property (weak, nonatomic) IBOutlet UILabel *createName;//创建人的名字
@property (weak, nonatomic) IBOutlet UILabel *createDepar;//创建人的部门
@property (weak, nonatomic) IBOutlet UILabel *createTime;//创建时间
@property (weak, nonatomic) IBOutlet UILabel *taskTitle;//任务标题
@property (weak, nonatomic) IBOutlet UIView *lineView;//下面绿色的条
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;//下面的滚动视图

@end

@implementation TaskDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务详情";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    //初始化界面
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
    _taskDetailView = [[TaskDetailView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.bottomScrollView.frame.size.height)];
    [self.bottomScrollView addSubview:_taskDetailView];
    _taskDiscussView = [[TaskDiscussView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, self.bottomScrollView.frame.size.height)];
    [self.bottomScrollView addSubview:_taskDiscussView];
    _taskFileView = [[TaskFileView alloc] initWithFrame:CGRectMake(2 *MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, self.bottomScrollView.frame.size.height)];
    [self.bottomScrollView addSubview:_taskFileView];
    // Do any additional setup after loading the view from its nib.
}
- (void)dataDidChange {
    _taskModel = self.data;
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
    self.lineView.center = CGPointMake(sender.center.x, self.lineView.center.y);
    int index = sender.tag - 1000;
    [self.bottomScrollView setContentOffset:CGPointMake(index * MAIN_SCREEN_WIDTH, 0) animated:YES];
}

@end
