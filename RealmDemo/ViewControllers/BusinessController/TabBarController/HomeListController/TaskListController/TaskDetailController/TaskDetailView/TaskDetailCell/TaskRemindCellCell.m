//
//  TaskRemindCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskRemindCellCell.h"
#import "TaskModel.h"

@interface TaskRemindCellCell ()
@property (weak, nonatomic) IBOutlet UIView *remindTime;

@end

@implementation TaskRemindCellCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    TaskModel *taskModel = self.data;
    for (UIView *view in self.remindTime.subviews) {
        [view removeFromSuperview];
    }
    NSArray *array = [taskModel.alert_date_list componentsSeparatedByString:@","];
    for (int index = 0; index < array.count; index ++) {
        NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:[array[index] integerValue] / 1000];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake((self.remindTime.frame.size.width / 2.f) * (index % 2), (index / 2) * 30, (self.remindTime.frame.size.width / 2.f), 15);
        if(createDate.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970)
            [btn setImage:[UIImage imageNamed:@"btn_select_icon"] forState:UIControlStateNormal];
        else
            [btn setImage:[UIImage imageNamed:@"btn_nomaril_icon"] forState:UIControlStateNormal];
        [btn setTitle:[NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",createDate.year,createDate.month,createDate.day,createDate.hour,createDate.minute] forState:UIControlStateNormal];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
