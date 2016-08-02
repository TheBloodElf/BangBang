//
//  TaskDetailCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDetailCell.h"
#import "TaskModel.h"

@interface TaskDetailCell ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *taskDetail;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation TaskDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.taskDetail.delegate = self;
    // Initialization code
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    TaskModel *model = self.data;
    model.descriptionStr = textView.text;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    if([NSString isBlank:textView.text])
        self.detailLabel.hidden = NO;
    else
        self.detailLabel.hidden = YES;
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    if([NSString isBlank:model.descriptionStr])
        self.detailLabel.hidden = NO;
    else 
        self.detailLabel.hidden = YES;
    
    self.taskDetail.text = model.descriptionStr;
}

@end
