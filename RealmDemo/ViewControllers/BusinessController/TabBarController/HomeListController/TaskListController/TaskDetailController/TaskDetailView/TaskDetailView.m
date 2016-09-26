//
//  TaskDetailView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDetailView.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "TaskDetailBottomOpView.h"

#import "TaskDetailCellCell.h"
#import "TaskInchargeCellCell.h"
#import "TaskMemberCellCell.h"
#import "TaskFinishCellCell.h"
#import "TaskRemindCellCell.h"
#import "TaskFinishStatusCell.h"

@interface TaskDetailView ()<UITableViewDelegate,UITableViewDataSource,TaskDetailBottomOpDelegate> {
    UserManager *_userManager;
    TaskModel *_taskModel;
    UITableView *_tableView;
    TaskDetailBottomOpView *_taskDetailBottomOpView;
}
@end

@implementation TaskDetailView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _userManager = [UserManager manager];
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _taskDetailBottomOpView = [[TaskDetailBottomOpView alloc] initWithFrame:CGRectMake(0, frame.size.height - 40, MAIN_SCREEN_WIDTH, 40)];
        _taskDetailBottomOpView.delegate = self;
        [self addSubview:_taskDetailBottomOpView];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"TaskDetailCellCell" bundle:nil] forCellReuseIdentifier:@"TaskDetailCellCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"TaskInchargeCellCell" bundle:nil] forCellReuseIdentifier:@"TaskInchargeCellCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"TaskMemberCellCell" bundle:nil] forCellReuseIdentifier:@"TaskMemberCellCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"TaskFinishCellCell" bundle:nil] forCellReuseIdentifier:@"TaskFinishCellCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"TaskRemindCellCell" bundle:nil] forCellReuseIdentifier:@"TaskRemindCellCell"];
        [_tableView registerNib:[UINib nibWithNibName:@"TaskFinishStatusCell" bundle:nil] forCellReuseIdentifier:@"TaskFinishStatusCell"];
        [self addSubview:_tableView];
    }
    return self;
}

- (void)dataDidChange {
    //这里不用获取详情了，因为由父控制器获取完成了再传进来的
    _taskModel = self.data;
    //判断自己是否有操作按钮
    BOOL haveOpertion = NO;
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_taskModel.company_no];
    //如果是负责人
    if([_taskModel.incharge isEqualToString:employee.employee_guid]) {
        if(_taskModel.status == 1 || _taskModel.status == 2 || _taskModel.status == 6)
            haveOpertion = YES;
    }
    //如果是创建者
    if([_taskModel.createdby isEqualToString:employee.employee_guid]) {
        if(_taskModel.status == 1 || _taskModel.status == 2 || _taskModel.status == 4 || _taskModel.status == 6)
            haveOpertion = YES;
    }
    //调整表格视图和操作视图的位置
    if(haveOpertion == YES) {
        _tableView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height - 40);
        _taskDetailBottomOpView.data = _taskModel;
    } else {
        _tableView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height);
    }
    [_tableView reloadData];
}
#pragma mark -- TaskDetailBottomOpDelegate
//接收
- (void)acceptClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(acceptClicked:task:)]) {
        [self.delegate acceptClicked:btn task:_taskModel];
    }
}
//终止
- (void)stopClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(stopClicked:task:)]) {
        [self.delegate stopClicked:btn task:_taskModel];
    }
}
//退回
- (void)returnClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(returnClicked:task:)]) {
        [self.delegate returnClicked:btn task:_taskModel];
    }
}
//通过
- (void)passClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(passClicked:task:)]) {
        [self.delegate passClicked:btn task:_taskModel];
    }
}
//提交
- (void)submitClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(submitClicked:task:)]) {
        [self.delegate submitClicked:btn task:_taskModel];
    }
}
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 4;
    if(_taskModel.status == 4 || _taskModel.status == 6 || _taskModel.status == 7 || _taskModel.status == 8)
        count ++;
    return count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1)
        return 2;
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if(indexPath.section == 0) {
        if([NSString isBlank:_taskModel.descriptionStr]) {
            height = 45 + [@"无任务描述" textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 20, 100000)].height + 5;
        } else {
            height = 45 + [_taskModel.descriptionStr textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 20, 100000)].height + 5;
        }
    } else if (indexPath.section == 1) {
        if(indexPath.row == 0)//负责人
            height = 63;
        else {//知悉人
            height = 63;
        }
    } else if (indexPath.section == 2) {
        height = 63;
    } else if (indexPath.section == 3) {
        if([NSString isBlank:_taskModel.alert_date_list])
            height = 63;
        else {
            NSArray *array = [_taskModel.alert_date_list componentsSeparatedByString:@","];
            int count = array.count / 2;
            if(array.count % 2 != 0)
                count ++;
            height = count * 15 + (count - 1) * 15 + 48;
        }
    } else if (indexPath.section == 4) {
        NSMutableString *str = [@"[完成理由]" mutableCopy];
        if(_taskModel.status == 4) {
            [str appendString:_taskModel.finish_comment];
        } else {
            [str appendString:_taskModel.approve_comment];
        }
        height = 84 + [str textSizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 20, 1000)].height + 5;
    }
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskDetailCellCell" forIndexPath:indexPath];
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TaskInchargeCellCell" forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"TaskMemberCellCell" forIndexPath:indexPath];
        }
    } else if(indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskFinishCellCell" forIndexPath:indexPath];
    } else if(indexPath.section == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskRemindCellCell" forIndexPath:indexPath];
    } else if (indexPath.section == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskFinishStatusCell" forIndexPath:indexPath];
    }
    
    cell.data = _taskModel;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1 && indexPath.row == 1) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(lookMember)]) {
            [self.delegate lookMember];
        }
    }
}

@end
