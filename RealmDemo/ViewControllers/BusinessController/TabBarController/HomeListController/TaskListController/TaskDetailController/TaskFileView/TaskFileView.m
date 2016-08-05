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

@interface TaskFileView ()<UITableViewDelegate,UITableViewDataSource,TaskFileImageDelegate,UIDocumentInteractionControllerDelegate> {
    TaskModel *_taskModel;
    UITableView *_tableView;
    NSMutableArray<TaskAttachModel*> *_taskAttachModelArr;
}

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@end

@implementation TaskFileView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _taskAttachModelArr = [@[] mutableCopy];
        UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [uploadBtn setBackgroundColor:[UIColor lightGrayColor]];
        [uploadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        uploadBtn.frame = CGRectMake(10, frame.size.height - 40, MAIN_SCREEN_WIDTH - 20, 30);
        uploadBtn.layer.cornerRadius = 5;
        uploadBtn.clipsToBounds = YES;
        [uploadBtn setTitle:@"上传附件" forState:UIControlStateNormal];
        [self addSubview:uploadBtn];
        [uploadBtn addTarget:self action:@selector(uploadClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, frame.size.height - 40) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"TaskFileImageCell" bundle:nil] forCellReuseIdentifier:@"TaskFileImageCell"];
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
    }
    return self;
}
- (void)dataDidChange {
    _taskModel = [self.data deepCopy];
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
        [_tableView reloadData];
    }];
}
- (void)uploadClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(uploadTaskFile)]) {
        [self.delegate uploadTaskFile];
    }
}
#pragma mark -- UITableViewDelegate
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
    //url 为需要调用第三方打开的文件地址
    NSURL *url = file.attachment.locFilePath;
    _documentInteractionController = [UIDocumentInteractionController
                                      interactionControllerWithURL:url];
    [_documentInteractionController setDelegate:self];
    [_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self animated:YES];
}

@end
