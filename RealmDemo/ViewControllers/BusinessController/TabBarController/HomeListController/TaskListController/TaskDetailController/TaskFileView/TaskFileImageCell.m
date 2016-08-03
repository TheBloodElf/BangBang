//
//  TaskFileImageCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskFileImageCell.h"
#import "TaskAttachModel.h"

@interface TaskFileImageCell ()
@property (weak, nonatomic) IBOutlet UILabel *fileName;

@end

@implementation TaskFileImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dataDidChange {
    TaskAttachModel *model = self.data;
    self.fileName.text = model.attachment.file_name;
}
- (IBAction)attachDelete:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(TaskFileImageDelete:)]) {
        [self.delegate TaskFileImageDelete:self.data];
    }
}

@end
