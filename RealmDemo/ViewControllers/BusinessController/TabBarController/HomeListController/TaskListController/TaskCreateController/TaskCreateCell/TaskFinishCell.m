//
//  TaskFinishCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskFinishCell.h"
#import "TaskModel.h"

@interface TaskFinishCell ()
@property (weak, nonatomic) IBOutlet UILabel *finishLabel;
@end

@implementation TaskFinishCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.enddate_utc / 1000];
    self.finishLabel.text = [NSString stringWithFormat:@"%ld-%02ld-%02ld %02ld:%02ld",(long)date.year,date.month,date.day,date.hour,date.minute];
}

@end
