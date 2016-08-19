//
//  TodayTableViewCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TodayTableViewCell.h"
#import "TodayCalendarModel.h"
#import "NSObject+data.h"
#import "NSDate+Format.h"
#import "NSString+isBlank.h"

@interface TodayTableViewCell  ()


@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UILabel *endDate;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineHeight;

@end

@implementation TodayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.lineHeight.constant = 0.5;
    // Initialization code
}
- (void)dataDidChange {
    TodayCalendarModel *model = self.data;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:model.begindate_utc / 1000];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:model.enddate_utc / 1000];
    self.startDate.text = [NSString stringWithFormat:@"%02ld:%02ld",startDate.hour,startDate.minute];
    self.endDate.text = [NSString stringWithFormat:@"~%02ld:%02ld",endDate.hour,endDate.minute];
    self.title.text = model.event_name;
    if([NSString isBlank:model.descriptionStr])
        self.descriptionLab.text = @"无日程描述";
    else
        self.descriptionLab.text = model.descriptionStr;
}

@end
