//
//  TaskDiscussView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDiscussView.h"
#import "UserHttp.h"
#import "TaskModel.h"
#import "TaskCommentModel.h"
#import "NoResultView.h"

#import "TaskOtherCommentCell.h"

@interface TaskDiscussView ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,TaskOtherCommentDelegate> {
    UITableView *_tableView;
    UserManager *_userManager;
    TaskModel *_taskModel;
    UIView *_bottomView;//下面的操作视图
    NSMutableArray<TaskCommentModel *> *_taskCommentModelArr;//评论列表
    TaskCommentModel *_currCommentModel;//当前需要发送的评论
    
    NSRange _userSelectRange;//用户输入@时的位置
    NoResultView *_noResultView;
}

@end

@implementation TaskDiscussView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _userManager = [UserManager manager];
        _currCommentModel = [TaskCommentModel new];
        _currCommentModel.reply_employeeguid = @"";
        _currCommentModel.reply_employeename = @"";
        _taskCommentModelArr = [@[] mutableCopy];
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 48, MAIN_SCREEN_WIDTH, 48)];
        _bottomView.userInteractionEnabled = YES;
        _bottomView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        //弄一个背景色
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(15, 9, MAIN_SCREEN_WIDTH - 30, 30)];
        whiteView.backgroundColor = [UIColor whiteColor];
        whiteView.layer.cornerRadius = 15;
        whiteView.clipsToBounds = YES;
        whiteView.tag = 1001;
        [_bottomView addSubview:whiteView];
        //左边专门用来显示@的视图
        UIButton *nameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nameBtn.frame = CGRectMake(0, 0, 0, 0);
        nameBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [nameBtn addTarget:self action:@selector(clearRepClicked:) forControlEvents:UIControlEventTouchUpInside];
        nameBtn.tag = 1002;
        [nameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [whiteView addSubview:nameBtn];
        
        UIButton *deleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleBtn.frame = CGRectMake(0, 0, 0, 0);
        [deleBtn setBackgroundImage:[UIImage imageNamed:@"home_add_delete"] forState:UIControlStateNormal];
        deleBtn.tag = 1004;
        [nameBtn addSubview:deleBtn];
        //右边输入文字的地方
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, whiteView.frame.size.width - 15, 30)];
        textField.backgroundColor = [UIColor whiteColor];
        textField.placeholder = @"输入内容...";
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        textField.font = [UIFont systemFontOfSize:14];
        textField.tag = 1003;
        textField.layer.borderColor = [UIColor whiteColor].CGColor;
        [whiteView addSubview:textField];
        [self addSubview:_bottomView];
    }
    return self;
}
- (void)dataDidChange {
    _taskModel = [self.data deepCopy];
    [_tableView removeFromSuperview];
    //任务没有接收不能讨论
    if(_taskModel.status == 1) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"TaskOtherCommentCell" bundle:nil] forCellReuseIdentifier:@"TaskOtherCommentCell"];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
    } else {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height - 48) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"TaskOtherCommentCell" bundle:nil] forCellReuseIdentifier:@"TaskOtherCommentCell"];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
    }
    _currCommentModel.task_id = _taskModel.id;
    _currCommentModel.task_status = _taskModel.status;
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    _currCommentModel.created_by = employee.employee_guid;
    _currCommentModel.created_realname = employee.real_name;
    //获取最新的讨论信息
    [UserHttp getTaskComment:_taskModel.id handler:^(id data, MError *error) {
        if(error) {
            [self showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *dic in data) {
            TaskCommentModel *model = [TaskCommentModel new];
            [model mj_setKeyValues:dic];
            [array insertObject:model atIndex:0];
        }
        _taskCommentModelArr = array;
        _noResultView = nil;
        _noResultView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
        if(_taskCommentModelArr.count == 0)
            _tableView.tableFooterView = _noResultView;
        else
            _tableView.tableFooterView = [UIView new];
        [_tableView reloadData];
        if(_taskCommentModelArr.count != 0)
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_taskCommentModelArr.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //如果用户想要@某人 就进入选择界面
    if([string isEqualToString:@"@"]) {
        _userSelectRange = range;
        if(self.delegate && [self.delegate respondsToSelector:@selector(taskDiscussSelectPersion)]) {
            [self.delegate taskDiscussSelectPersion];
        }
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}
//选择@的人
- (void)setEmployee:(Employee*)employee {
    UIView *whiteView = [_bottomView viewWithTag:1001];
    UIButton *nameBtn = [whiteView viewWithTag:1002];
    UITextField *textField = [whiteView viewWithTag:1003];
    UIButton *deleBtn = [nameBtn viewWithTag:1004];
    //当前名字占的宽度
    CGFloat width = [[NSString stringWithFormat:@"@%@",employee.user_real_name] textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(10000, 30)].width;
    nameBtn.frame = CGRectMake(15, 0, width, 30);
    deleBtn.frame = CGRectMake(width - 10, 0, 10, 10);
    [nameBtn setTitle:[NSString stringWithFormat:@"@%@",employee.user_real_name] forState:UIControlStateNormal];
    
    textField.frame = CGRectMake(width + 15, 0, whiteView.frame.size.width - width - 15, 30);
    _currCommentModel.reply_employeename = employee.user_real_name;
    _currCommentModel.reply_employeeguid = employee.employee_guid;
}
- (void)selectCancle {
    UIView *whiteView = [_bottomView viewWithTag:1001];
    UITextField *textField = [whiteView viewWithTag:1003];
    textField.text = [textField.text stringByReplacingCharactersInRange:NSMakeRange(_userSelectRange.location, 0) withString:@"@"];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if([NSString isBlank:textField.text]) return YES;
   //添加评论
    [UserHttp addTaskComment:_currCommentModel.task_id taskStatus:_currCommentModel.task_status comment:textField.text createdby:_currCommentModel.created_by createdRealname:_currCommentModel.created_realname repEmployeeGuid:_currCommentModel.reply_employeeguid repEmployeeName:_currCommentModel.reply_employeename handler:^(id data, MError *error) {
        if(error) {
            [self showFailureTips:error.statsMsg];
            return ;
        }
        textField.text = @"";
        self.data = _taskModel;
    }];
    return YES;
}
- (void)clearRepClicked:(UIButton*)btn {
    UIView *whiteView = [_bottomView viewWithTag:1001];
    UIButton *nameBtn = [whiteView viewWithTag:1002];
    UITextField *textField = [whiteView viewWithTag:1003];
    nameBtn.frame = CGRectMake(15, 0, 0, 30);
    textField.frame = CGRectMake(15, 0, whiteView.frame.size.width - 15, 30);
    _currCommentModel.reply_employeename = @"";
    _currCommentModel.reply_employeeguid = @"";
}
#pragma mark -- TaskOtherCommentDelegate
- (void)TaskOtherAvaterClicked:(TaskCommentModel*)model {
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    if([model.created_by isEqualToString:employee.employee_guid]) {
        [self showMessageTips:@"不能回复自己"];
        return;
    }
    UIView *whiteView = [_bottomView viewWithTag:1001];
    UIButton *nameBtn = [whiteView viewWithTag:1002];
    UITextField *textField = [whiteView viewWithTag:1003];
    UIButton *deleBtn = [nameBtn viewWithTag:1004];
    //当前名字占的宽度
    CGFloat width = [[NSString stringWithFormat:@"@%@",model.created_realname] textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(10000, 30)].width;
    nameBtn.frame = CGRectMake(15, 0, width, 30);
    deleBtn.frame = CGRectMake(width - 10, 0, 10, 10);
    [nameBtn setTitle:[NSString stringWithFormat:@"@%@",model.created_realname] forState:UIControlStateNormal];
    
    textField.frame = CGRectMake(width + 15, 0, whiteView.frame.size.width - width - 15, 30);
    _currCommentModel.reply_employeename = model.created_realname;
    _currCommentModel.reply_employeeguid = model.created_by;
}
#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskCommentModelArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCommentModel *model = _taskCommentModelArr[indexPath.row];
    return [model.comment textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 53, 100000)].height + 74 + 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskOtherCommentCell" forIndexPath:indexPath];
    TaskOtherCommentCell *commentCell = (id)cell;
    commentCell.delegate = self;
    cell.data = _taskCommentModelArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
