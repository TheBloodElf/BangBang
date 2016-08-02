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
        
        _taskDetailBottomOpView = [[TaskDetailBottomOpView alloc] initWithFrame:CGRectMake(0, frame.size.height - 50, MAIN_SCREEN_WIDTH, 50)];
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
        [self addSubview:_tableView];
    }
    return self;
}

- (void)dataDidChange {
    _taskModel = self.data;
    //获取任务详情
    [self showLoadingTips:@"获取任务详情..."];
    [UserHttp getTaskInfo:_taskModel.id handler:^(id data, MError *error) {
        [self dismissTips];
        if(error) {
            [self showFailureTips:error.statsMsg];
            return ;
        }
        _taskModel = [[TaskModel alloc] initWithJSONDictionary:data];
        _taskModel.descriptionStr = data[@"description"];
        [_userManager upadteTask:_taskModel];
        [_tableView reloadData];
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
            _tableView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height - 50);
            _taskDetailBottomOpView.data = _taskModel;
        } else {
            _tableView.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.frame.size.height);
        }
    }];
}
#pragma mark -- TaskDetailBottomOpDelegate
//接收
- (void)acceptClicked:(UIButton*)btn {
    
}
//终止
- (void)stopClicked:(UIButton*)btn {
    
}
//退回
- (void)returnClicked:(UIButton*)btn {
    
}
//通过
- (void)passClicked:(UIButton*)btn {
    
}
//提交
- (void)submitClicked:(UIButton*)btn {
    
}
#pragma mark -- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1)
        return 2;
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 63;
    if(indexPath.section == 0) {
        height = 45 + [_taskModel.descriptionStr textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 20, 100000)].height;
    } else if (indexPath.section == 2) {
        if(indexPath.row == 0)
            height = 53;
        else {
            if([NSString isBlank:_taskModel.members])
                height = 0.001f;
        }
    } else if (indexPath.section == 3) {
        if([NSString isBlank:_taskModel.alert_date_list])
            height = 0.001f;
        else {
            NSArray *array = [_taskModel.alert_date_list componentsSeparatedByString:@","];
            int number = array.count / 2;
            if(number % 2 != 0)
                number ++;
            height = number * 15 + (number - 1) * 15 + 48;
        }
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
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TaskRemindCellCell" forIndexPath:indexPath];
    }
    
    cell.data = _taskModel;
    
    return cell;
}

@end
