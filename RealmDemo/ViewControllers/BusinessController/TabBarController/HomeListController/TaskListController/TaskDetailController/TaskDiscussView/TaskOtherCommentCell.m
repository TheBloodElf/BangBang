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
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (weak, nonatomic) IBOutlet UILabel *replyNameLabel;

@end

@implementation TaskOtherCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.avaterImage zy_cornerRadiusRoundingRect];
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
    
    if([NSString isBlank:model.reply_employeename]) {
        self.replyLabel.hidden = YES;
        self.replyNameLabel.hidden = YES;
    } else {
        self.replyLabel.hidden = NO;
        self.replyNameLabel.hidden = NO;
    }
    
    [self.avaterImage sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.nameLabel.text = model.created_realname;
    self.contentLabel.text = model.comment;
    NSDate *currDate = [NSDate dateWithTimeIntervalSince1970:model.createdon_utc / 1000];
    self.timeLabel.text = [NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",currDate.year,currDate.month,currDate.day,currDate.hour,currDate.minute];
    self.replyNameLabel.text = model.reply_employeename;
    
    
}
//某人头像被点击
- (IBAction)avaterClicked:(id)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(TaskOtherAvaterClicked:)]) {
        [self.delegate TaskOtherAvaterClicked:self.data];
    }
}

@end
