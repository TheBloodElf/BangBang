//
//  TaskFileImageCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskFileImageCell.h"
#import "TaskAttachModel.h"
#import "FileManager.h"

@interface TaskFileImageCell () {
    FileManager *_fileManager;
}
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@end

@implementation TaskFileImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _fileManager = [FileManager shareManager];
}

- (void)dataDidChange {
    TaskAttachModel *model = self.data;
    self.fileName.text = model.attachment.file_name;
    //判断本地是否有一样的文件，如果有一样的，就不下载了 并且改变按钮的文字
    if([_fileManager fileIsExit:model.attachment.file_name]) {
        [self.rightBtn setTitle:@"查看" forState:UIControlStateNormal];
        model.attachment.locFilePath = [_fileManager fileUrl:model.attachment.file_name];
        [self.rightBtn addTarget:self action:@selector(attachLook:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.rightBtn setTitle:@"下载" forState:UIControlStateNormal];
        [self.rightBtn addTarget:self action:@selector(attachDelete:) forControlEvents:UIControlEventTouchUpInside];
    }
}
- (void)attachLook:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(TaskFileLook:)]) {
        [self.delegate TaskFileLook:self.data];
    }
}
- (void)attachDelete:(UIButton*)btn {
    TaskAttachModel *model = self.data;
    [self.rightBtn setTitle:@"下载..." forState:UIControlStateNormal];
    [_fileManager downFile:model.attachment.file_url handler:^(id data, MError *error) {
        if(error) {
            [self.rightBtn setTitle:@"下载" forState:UIControlStateNormal];
            return ;
        }
        model.attachment.locFilePath = [_fileManager fileUrl:data[@"suggestedFilename"]];
        [self.rightBtn setTitle:@"查看" forState:UIControlStateNormal];
        [self.rightBtn addTarget:self action:@selector(attachLook:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

@end
