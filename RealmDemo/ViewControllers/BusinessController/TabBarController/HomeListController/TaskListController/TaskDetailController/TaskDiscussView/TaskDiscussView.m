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
        _tableView.tableFooterView = [UIView new];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self addSubview:_tableView];
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 48, MAIN_SCREEN_WIDTH, 48)];
        _bottomView.userInteractionEnabled = YES;
        _bottomView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 9, MAIN_SCREEN_WIDTH - 46 - 15, 30)];
        textField.backgroundColor = [UIColor whiteColor];
        textField.placeholder = @"输入内容...";
        textField.layer.cornerRadius = 15;
        textField.clipsToBounds = YES;
        textField.layer.borderWidth = 1;
        textField.tag = 1000;
        textField.delegate = self;
        textField.layer.borderColor = [UIColor whiteColor].CGColor;
        [_bottomView addSubview:textField];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(MAIN_SCREEN_WIDTH - 46, 9, 46, 30);
        [btn setTitle:@"发送" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
        btn.tag = 1001;
        [_bottomView addSubview:btn];
        [btn addTarget:self action:@selector(sendClicked:) forControlEvents:UIControlEventTouchUpInside];
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
            [array addObject:model];
        }
        _taskCommentModelArr = array;
        [_tableView reloadData];
    }];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
     [UIView animateWithDuration:0.2 animations:^{
        _bottomView.frame = CGRectMake(0, self.frame.size.height - 48 - 250, MAIN_SCREEN_WIDTH, 48);
        _tableView.frame = CGRectMake(0, -250, MAIN_SCREEN_WIDTH, self.frame.size.height - 48);
     }];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    [UIView animateWithDuration:0.2 animations:^{
        _bottomView.frame = CGRectMake(0, self.frame.size.height - 48, MAIN_SCREEN_WIDTH, 48);
        _tableView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height - 48);
    }];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        _bottomView.frame = CGRectMake(0, self.frame.size.height - 48, MAIN_SCREEN_WIDTH, 48);
        _tableView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height - 48);
    }];
    return YES;
}
- (void)sendClicked:(UIButton*)btn {
    [self endEditing:YES];
    UITextField *text = [_bottomView viewWithTag:1000];
    if([NSString isBlank:text.text]) return;
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    [UserHttp addTaskComment:_taskModel.id taskStatus:_taskModel.status comment:text.text createdby:employee.employee_guid createdRealname:employee.real_name handler:^(id data, MError *error) {
        if(error) {
            [self showFailureTips:error.statsMsg];
            return ;
        }
        text.text = @"";
        self.data = _taskModel;
    }];
}
#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskCommentModelArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCommentModel *model = _taskCommentModelArr[indexPath.row];
    return [model.comment textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 53, 100000)].height + 77 + 10;
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
