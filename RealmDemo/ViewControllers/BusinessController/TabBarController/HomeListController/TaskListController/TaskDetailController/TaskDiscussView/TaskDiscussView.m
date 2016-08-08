//
//  TaskDiscussView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDiscussView.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "TaskModel.h"
#import "TaskCommentModel.h"

#import "TaskOtherCommentCell.h"
#import "TaskOwnerCommentCell.h"

@interface TaskDiscussView ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate> {
    UITableView *_tableView;
    UserManager *_userManager;
    TaskModel *_taskModel;
    UIView *_bottomView;//下面的操作视图
    NSMutableArray<TaskCommentModel *> *_taskCommentModelArr;//评论列表
}

@end

@implementation TaskDiscussView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _userManager = [UserManager manager];
        _taskCommentModelArr = [@[] mutableCopy];
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, frame.size.height - 48) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"TaskOwnerCommentCell" bundle:nil] forCellReuseIdentifier:@"TaskOwnerCommentCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"TaskOtherCommentCell" bundle:nil] forCellReuseIdentifier:@"TaskOtherCommentCell"];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 48, MAIN_SCREEN_WIDTH, 48)];
        _bottomView.userInteractionEnabled = YES;
        _bottomView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 9, MAIN_SCREEN_WIDTH - 30, 30)];
        textField.backgroundColor = [UIColor whiteColor];
        textField.placeholder = @"输入内容...";
        textField.layer.cornerRadius = 15;
        textField.clipsToBounds = YES;
        textField.layer.borderWidth = 1;
        textField.tag = 1000;
        textField.returnKeyType = UIReturnKeyDone;
        textField.delegate = self;
        textField.layer.borderColor = [UIColor whiteColor].CGColor;
        [_bottomView addSubview:textField];
        [self addSubview:_bottomView];
    }
    return self;
}
- (void)dataDidChange {
    _taskModel = [self.data deepCopy];
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
        [_tableView reloadData];
        if(_taskCommentModelArr.count != 0)
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_taskCommentModelArr.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    UITextField *text = (id)[_bottomView viewWithTag:1000];
    if([NSString isBlank:text.text]) return YES;
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    [UserHttp addTaskComment:_taskModel.id taskStatus:_taskModel.status comment:text.text createdby:employee.employee_guid createdRealname:employee.real_name handler:^(id data, MError *error) {
        if(error) {
            [self showFailureTips:error.statsMsg];
            return ;
        }
        text.text = @"";
        self.data = _taskModel;
    }];

    return YES;
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
    UITableViewCell *cell = nil;
    TaskCommentModel *model = _taskCommentModelArr[indexPath.row];
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    if([model.created_by isEqualToString:employee.employee_guid])
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskOwnerCommentCell" forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskOtherCommentCell" forIndexPath:indexPath];
    cell.data = model;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
