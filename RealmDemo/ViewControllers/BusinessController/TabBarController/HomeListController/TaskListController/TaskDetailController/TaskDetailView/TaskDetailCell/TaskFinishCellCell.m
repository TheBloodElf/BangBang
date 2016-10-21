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
    //截止时间
    NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:model.enddate_utc / 1000];
    self.finishTime.text = [NSString stringWithFormat:@"%d-%02ld-%02ld %02ld:%02ld",createDate.year,createDate.month,createDate.day,createDate.hour,createDate.minute];
    self.detailLabel.hidden = YES;
    //终止就不显示后面的时间
    if(model.status == 8) return;
    self.detailLabel.hidden = NO;
    //如果是已经完成就按照完成的时间来计算
    NSDate *compareDate = model.status == 7 ? [NSDate dateWithTimeIntervalSince1970:model.updatedon_utc / 1000] : [NSDate date];
    //算出离任务结束还有多少秒
    int64_t timeDate = compareDate.timeIntervalSince1970 - model.enddate_utc / 1000;
    //是否超过了任务结束时间
    self.detailLabel.textColor = timeDate > 0 ? [UIColor redColor] : [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    NSString *firstStr = timeDate > 0 ? @"超" : @"余";
    timeDate = llabs(timeDate);
    int day = (int)timeDate / (24 * 60 * 60);
    int hour = (int)timeDate % (24 * 60 * 60) / (60 * 60);
    int minute = (int)timeDate % (60 * 60) / 60;
    self.detailLabel.text = [NSString stringWithFormat:@"%@：%d天%d时%d分",firstStr,day,hour,minute];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
