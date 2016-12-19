//
//  TaskDiscussNewView.m
//  RealmDemo
//
//  Created by Mac on 2016/11/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDiscussNewView.h"
#import "UserHttp.h"
#import "TaskModel.h"
#import "TaskCommentModel.h"
#import "NoResultView.h"
#import "TaskOtherCommentCell.h"
//输入框最大最小行数
#define TextView_Content_Min_Lines 1
#define TextView_Content_Max_Lines 3
#define TextView_Text_Font_Size     15

@interface TaskDiscussNewView ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,TaskOtherCommentDelegate> {
    UserManager *_userManager;
    TaskModel *_taskModel;
    NSMutableArray<TaskCommentModel *> *_taskCommentModelArr;//评论列表
    TaskCommentModel *_currCommentModel;//当前需要发送的评论
    NoResultView *_noResultView;
    NSRange _repEmployeeRange;//被回复的人的字符串范围
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;//展示数据的表格视图
@property (weak, nonatomic) IBOutlet UITextView *textView;//内容输入框
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;//输入框的高度
@property (weak, nonatomic) IBOutlet UILabel *phLabel;//占位符号

@end

@implementation TaskDiscussNewView

- (void)setupUI {
    _userManager = [UserManager manager];
    _currCommentModel = [TaskCommentModel new];
    _taskCommentModelArr = [@[] mutableCopy];
    //设置表格视图
    [_tableView registerNib:[UINib nibWithNibName:@"TaskOtherCommentCell" bundle:nil] forCellReuseIdentifier:@"TaskOtherCommentCell"];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.tableFooterView = [UIView new];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //设置输入视图
    _textView.layer.cornerRadius = 5.f;
    _textView.clipsToBounds = YES;
    _textView.returnKeyType = UIReturnKeySend;
    _textView.delegate = self;
    _textView.scrollEnabled = NO;//这句话是重点，不然有奇怪的现象
    _textView.scrollsToTop = NO;
    _textView.enablesReturnKeyAutomatically = YES;
    _textViewHeight.constant = ceil(_textView.font.lineHeight * TextView_Content_Min_Lines + _textView.textContainerInset.top + _textView.textContainerInset.bottom);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:_textView];
}
- (void)dataDidChange {
    _taskModel = self.data;
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    _currCommentModel.created_by = employee.employee_guid;
    _currCommentModel.created_realname = employee.real_name;
    _currCommentModel.task_id = _taskModel.id;
    _currCommentModel.task_status = _taskModel.status;
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
#pragma mark -- 
#pragma mark -- UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //如果是确认被点击就发送消息
    if([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    //如果是删除操作
    if([NSString isBlank:text]) {
        //如果有被回复的人
        if(_repEmployeeRange.length != 0)
            //并且删除范围内有被回复的人的字符串
            if(range.location <_repEmployeeRange.length) {
                //删除的字符串就在被回复的人的字符串当中 就删除被回复人的字符串
                if(range.location + range.length <= _repEmployeeRange.length)
                    range = NSMakeRange(0, _repEmployeeRange.length);
                else//删除的字符串包括了外面的字符串 就要把被回复字符串一起包含
                    range = NSMakeRange(0, range.location + range.length);
                NSString *currStr = [textView.text stringByReplacingCharactersInRange:range withString:@""];
                _textView.text = currStr;
                _repEmployeeRange = NSMakeRange(0, 0);
                _currCommentModel.reply_employeename = @"";
                _currCommentModel.reply_employeeguid = @"";
                [self textDidChange];//直接赋值不会触发UITextViewTextDidChangeNotification方法
                return NO;
            }
    }
    //如果是@符号就进入选择界面
    if([text isEqualToString:@"@"]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(taskDiscussSelectPersion)]) {
            [self.delegate taskDiscussSelectPersion];
        }
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)textDidChange {
    NSInteger height = ceilf([_textView sizeThatFits:CGSizeMake(_textView.bounds.size.width, MAXFLOAT)].height);
    if(height >= ceil(_textView.font.lineHeight * TextView_Content_Max_Lines + _textView.textContainerInset.top + _textView.textContainerInset.bottom)) {
        _textView.scrollEnabled = YES;
        height = ceil(_textView.font.lineHeight * TextView_Content_Max_Lines + _textView.textContainerInset.top + _textView.textContainerInset.bottom);
    } else
        _textView.scrollEnabled = NO;
    _textViewHeight.constant = height;
    [_textView.superview layoutIfNeeded];
    //显示或者隐藏占位符号
    _phLabel.hidden = ![NSString isBlank:_textView.text];
}
//发送消息
- (void)sendMessage {
    [_textView resignFirstResponder];
    //需要发送的字符串
    NSString *sendmessage = _textView.text;
    //如果有回复人，去掉回复字符串
    if(_repEmployeeRange.length != 0)
        sendmessage = [sendmessage stringByReplacingCharactersInRange:_repEmployeeRange withString:@""];
    //添加评论
    [UserHttp addTaskComment:_currCommentModel.task_id taskStatus:_currCommentModel.task_status comment:sendmessage createdby:_currCommentModel.created_by createdRealname:_currCommentModel.created_realname repEmployeeGuid:_currCommentModel.reply_employeeguid repEmployeeName:_currCommentModel.reply_employeename handler:^(id data, MError *error) {
        if(error) {
            [self showFailureTips:error.statsMsg];
            return ;
        }
        _textView.text = @"";
        [self textDidChange];//直接赋值不会触发UITextViewTextDidChangeNotification方法
        _repEmployeeRange = NSMakeRange(0, 0);
        _currCommentModel.reply_employeeguid = @"";
        _currCommentModel.reply_employeename = @"";
        self.data = _taskModel;
    }];
}
//选择@的人
- (void)setEmployee:(Employee*)employee {
    //得到当前输入框的字符串
    NSString *currStr = _textView.text;
    //是不是之前已经@过某个人，如果有那么就去除上一个人
    if(_repEmployeeRange.length != 0) {
        currStr = [currStr stringByReplacingCharactersInRange:_repEmployeeRange withString:@""];
    }
    _repEmployeeRange = NSMakeRange(0, employee.user_real_name.length + 1);
    _currCommentModel.reply_employeename = employee.user_real_name;
    _currCommentModel.reply_employeeguid = employee.employee_guid;
    //设置当前正确的字符串
    currStr = [currStr stringByReplacingCharactersInRange:NSMakeRange(0, 0) withString:[NSString stringWithFormat:@"@%@ ",employee.user_real_name]];
    _textView.text = currStr;
    [self textDidChange];//直接赋值不会触发UITextViewTextDidChangeNotification方法
}
//取消选择
- (void)selectCancle {
    
}
#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskCommentModelArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCommentModel *model = _taskCommentModelArr[indexPath.row];
    return [model.comment textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 53, 100000)].height + 74 + 22;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskOtherCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskOtherCommentCell" forIndexPath:indexPath];
    cell.data = _taskCommentModelArr[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark --
#pragma mark -- TaskOtherCommentDelegate
- (void)TaskOtherRepClicked:(TaskCommentModel*)model {
    Employee *owner = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    Employee *other = [Employee new];
    for (Employee *employee in [_userManager getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no status:5]) {
        if([employee.employee_guid isEqualToString:model.created_by]) {
            other = employee;
            break;
        }
    }
    if([owner.employee_guid isEqualToString:other.employee_guid]) {
        [self showMessageTips:@"不能回复自己"];
        return;
    }
    //有可能他退圈子了，就不用回复了
    if(other.id == 0) {
        [self showMessageTips:@"圈中不存在此人"];
        return;
    }
    [self setEmployee:other];
}

@end
