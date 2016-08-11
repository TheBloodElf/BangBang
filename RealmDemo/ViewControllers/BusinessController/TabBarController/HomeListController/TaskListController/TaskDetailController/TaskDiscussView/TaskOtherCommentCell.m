//
//  TaskOtherCommentCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskOtherCommentCell.h"
#import "TaskCommentModel.h"

@interface TaskOtherCommentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation TaskOtherCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avaterImage.clipsToBounds = YES;
    self.avaterImage.layer.cornerRadius = 14;
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClicked:)];
    [self.contentLabel addGestureRecognizer:longTap];
    //禁用双击手势
    // Initialization code
}
- (void)longClicked:(id)longTap {
    if(self.window.rootViewController.view.frame.origin.y < 0) {
        [[IQKeyboardManager sharedManager] resignFirstResponder];
    }
}
- (void)dataDidChange {
    TaskCommentModel *model = self.data;
    [self.avaterImage sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.nameLabel.text = model.created_realname;
    self.contentLabel.text = model.comment;
    NSDate *currDate = [NSDate dateWithTimeIntervalSince1970:model.createdon_utc / 1000];
    self.timeLabel.text = [NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",currDate.year,currDate.month,currDate.day,currDate.hour,currDate.minute];
}

@end
