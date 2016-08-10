//
//  AttachVideoCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/10.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AttachVideoCell.h"
#import "Attachment.h"
#import "FileManager.h"

@interface AttachVideoCell  () {
    FileManager *_fileManager;
}

@property (weak, nonatomic) IBOutlet UIButton *isSelectedBtn;
@property (weak, nonatomic) IBOutlet UIButton *attachImage;
@property (weak, nonatomic) IBOutlet UILabel *attachName;
@property (weak, nonatomic) IBOutlet UILabel *attachSize;
@property (weak, nonatomic) IBOutlet UILabel *attachCreateDate;

@end

@implementation AttachVideoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _fileManager = [FileManager shareManager];
    // Initialization code
}

- (void)dataDidChange {
    Attachment *attachment = self.data;
    self.isSelectedBtn.selected = attachment.isSelected;
    //得到视频的第一张图片
    self.attachName.text = attachment.fileName;
    self.attachSize.text = [NSString stringWithFormat:@"%dk",attachment.fileSize];
    self.attachCreateDate.text = [NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",attachment.fileCreateDate.year,attachment.fileCreateDate.month,attachment.fileCreateDate.day,attachment.fileCreateDate.hour,attachment.fileCreateDate.minute];
}
@end
