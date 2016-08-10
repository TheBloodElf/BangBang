//
//  AttachDocumentCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/10.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AttachDocumentCell.h"
#import "Attachment.h"

@interface AttachDocumentCell ()

@property (weak, nonatomic) IBOutlet UIButton *isSelectedBtn;
@property (weak, nonatomic) IBOutlet UIButton *attachImage;
@property (weak, nonatomic) IBOutlet UILabel *attachName;
@property (weak, nonatomic) IBOutlet UILabel *attachSize;
@property (weak, nonatomic) IBOutlet UILabel *attachCreateDate;

@end

@implementation AttachDocumentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dataDidChange {
    Attachment *attachment = self.data;
    self.isSelectedBtn.selected = attachment.isSelected;
    [self.attachImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_%@",attachment.fileName.pathExtension]] forState:UIControlStateNormal];
    self.attachName.text = attachment.fileName;
    self.attachSize.text = [NSString stringWithFormat:@"%dk",attachment.fileSize];
    self.attachCreateDate.text = [NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",attachment.fileCreateDate.year,attachment.fileCreateDate.month,attachment.fileCreateDate.day,attachment.fileCreateDate.hour,attachment.fileCreateDate.minute];
}

@end
