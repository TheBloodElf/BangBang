//
//  TaskFinishCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskFinishCellCell.h"
#import "TaskModel.h"

@interface TaskFinishCellCell ()
@property (weak, nonatomic) IBOutlet UILabel *finishTime;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation TaskFinishCellCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:model.enddate_utc / 1000];
    self.finishTime.text = [NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",createDate.year,createDate.month,createDate.day,createDate.hour,createDate.minute];
    int64_t timeDate = model.enddate_utc / 1000 - [NSDate date].timeIntervalSince1970;
    //是不是超时了
    if(timeDate < 0) {
        timeDate = -timeDate;
        self.detailLabel.text = [NSString stringWithFormat:@"超：%d天%d时%d分",timeDate / (24 * 60 * 60),(timeDate % (24 * 60 * 60)) / (60 * 60),(timeDate % (60 * 60)) / 60];
        self.detailLabel.textColor = [UIColor redColor];
    } else {
        self.detailLabel.text = [NSString stringWithFormat:@"余：%d天%d时%d分",timeDate / (24 * 60 * 60),(timeDate % (24 * 60 * 60)) / (60 * 60),(timeDate % (60 * 60)) / 60];
        self.detailLabel.textColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
