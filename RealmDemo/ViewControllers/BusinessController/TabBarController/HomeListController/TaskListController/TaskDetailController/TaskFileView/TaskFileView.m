//
//  TaskFileView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskFileView.h"
#import "TaskFileImageCell.h"
#import "TaskAttachModel.h"
#import "TaskModel.h"
#import "UserHttp.h"
#import "NoResultView.h"

@interface TaskFileView ()<UITableViewDelegate,UITableViewDataSource,TaskFileImageDelegate> {
    TaskModel *_taskModel;
    UITableView *_tableView;
    NoResultView *_noResultView;
    NSMutableArray<TaskAttachModel*> *_taskAttachModelArr;
}

@end

@implementation TaskFileView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _taskAttachModelArr = [@[] mutableCopy];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, frame.size.height - 49, MAIN_SCREEN_WIDTH, 49);
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        [btn setTitle:@"附件上传" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(uploadClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        //添加一条上面的线条
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 49, MAIN_SCREEN_WIDTH, 0.5)];
        topLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:topLine];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, frame.size.height - 49) style:UITableViewStylePlain];
        _noResultView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"TaskFileImageCell" bundle:nil] forCellReuseIdentifier:@"TaskFileImageCell"];
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
    }
    return self;
}
- (void)dataDidChange {
    _taskModel = self.data;
    //获取最新的附件信息
    [UserHttp getTaskAttachment:_taskModel.id handler:^(id data, MError *error) {
        if(error) {
            [self showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *dic in data) {
            TaskAttachModel *model = [TaskAttachModel new];
            [model mj_setKeyValues:dic];
            [array addObject:model];
        }
        _taskAttachModelArr = array;
        if(_taskAttachModelArr.count == 0)
            _tableView.tableFooterView = _noResultView;
        else
            _tableView.tableFooterView = [UIView new];
        [_tableView reloadData];
    }];
}
- (void)uploadClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(uploadTaskFile)]) {
        [self.delegate uploadTaskFile];
    }
}
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //#BANG-445 任务附件cell高度调整
    return 54.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _taskAttachModelArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskFileImageCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"TaskFileImageCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.data = _taskAttachModelArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark -- TaskFileDown
//文件预览
- (void)TaskFileLook:(TaskAttachModel*)file {
    if(self.delegate && [self.delegate respondsToSelector:@selector(lookTaskFile:)]) {
        [self.delegate lookTaskFile:file.attachment.locFilePath];
    }
}
@end
