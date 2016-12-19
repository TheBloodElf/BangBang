//
//  TaskRemindCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskRemindCell.h"

@interface TaskRemindCell  ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation TaskRemindCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    NSDate *date = self.data;
    self.dateLabel.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld",(long)date.year,date.month,date.day,date.hour,date.minute];;
}

- (IBAction)deleClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(TaskRemindDeleteDate:)]) {
        [self.delegate TaskRemindDeleteDate:self.data];
    }
}

@end
