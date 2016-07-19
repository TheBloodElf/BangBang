//
//  CalenderEventTableViewCell.m
//  BangBang
//
//  Created by Xiaoyafei on 15/8/24.
//  Copyright (c) 2015年 Kiwaro. All rights reserved.
//

#import "CalenderEventTableViewCell.h"
#import "Calendar.h"

@interface CalenderEventTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UILabel *endDate;
@property (weak, nonatomic) IBOutlet UILabel *allDayDate;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLab;
@property (weak, nonatomic) IBOutlet UIImageView *emergencyImg;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleWithConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *alertImage;

@end

@implementation CalenderEventTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _status.layer.masksToBounds = YES;
    _status.layer.cornerRadius = _status.frame.size.height / 3.f;
    _status.layer.borderWidth = 1;
}

- (void)dataDidChange {
    Calendar *calendar = self.data;
    if (calendar.is_over_day && calendar.repeat_type == 0) {
        _startDate.hidden = NO;
        _endDate.hidden = NO;
        _allDayDate.hidden =YES;
        //开始时间
        static NSDateFormatter *startDateOverDayFormatter = nil;
        if (startDateOverDayFormatter == nil) {
            startDateOverDayFormatter = [[NSDateFormatter alloc] init];
            [startDateOverDayFormatter setDateFormat:@"MM/dd"];
        }
        NSDate *start = [NSDate dateWithTimeIntervalSince1970:calendar.begindate_utc/1000];
        NSString *startStr = [startDateOverDayFormatter stringFromDate:start];
        _startDate.text = startStr;
        
        //结束时间
        static NSDateFormatter *endDateOverFormatter = nil;
        if (endDateOverFormatter == nil) {
            endDateOverFormatter = [[NSDateFormatter alloc] init];
            [endDateOverFormatter setDateFormat:@"~MM/dd"];
        }
        NSDate *end = [NSDate dateWithTimeIntervalSince1970:calendar.enddate_utc/1000];
        NSString *endStr = [endDateOverFormatter stringFromDate:end];
        _endDate.text = endStr;
    }
    else if(calendar.is_allday){
        //开始时间
        _startDate.hidden = YES;
        _endDate.hidden = YES;
        static NSDateFormatter *startDateAllDayFormatter = nil;
        if (startDateAllDayFormatter == nil) {
            startDateAllDayFormatter = [[NSDateFormatter alloc] init];
            [startDateAllDayFormatter setDateFormat:@"MM/dd"];
        }
        NSDate *start = [NSDate dateWithTimeIntervalSince1970:calendar.begindate_utc/1000];
        NSString *startStr = [startDateAllDayFormatter stringFromDate:start];
        _allDayDate.text = startStr;
    }
    else{
        _startDate.hidden = NO;
        _endDate.hidden = NO;
        _allDayDate.hidden =YES;
        //开始时间
        static NSDateFormatter *startDateFormatter = nil;
        if (startDateFormatter == nil) {
            startDateFormatter = [[NSDateFormatter alloc] init];
            [startDateFormatter setDateFormat:@"HH:mm"];
        }
        NSDate *start = [NSDate dateWithTimeIntervalSince1970:calendar.begindate_utc/1000];
        NSString *startStr = [startDateFormatter stringFromDate:start];
        _startDate.text = startStr;
        
        //结束时间
        static NSDateFormatter *endDateFormatter = nil;
        if (endDateFormatter == nil) {
            endDateFormatter = [[NSDateFormatter alloc] init];
            [endDateFormatter setDateFormat:@"~HH:mm"];
        }
        NSDate *end = [NSDate dateWithTimeIntervalSince1970:calendar.enddate_utc/1000];
        NSString *endStr = [endDateFormatter stringFromDate:end];
        _endDate.text = endStr;
    }
    //标题
    _title.text = calendar.event_name;
    CGSize titleSize = [self sizeWithText:calendar.event_name font:[UIFont systemFontOfSize:17] maxSize:CGSizeMake(169, MAXFLOAT)];
    _titleWithConstraint.constant = titleSize.width + 1;
    
    //详情
    if (calendar.description.length > 0) {
        _descriptionLab.text = calendar.description;
    }
    else{
        _descriptionLab.text = @"暂无描述";
    }
    //状态
    
    if (calendar.status == 0) {
        _status.text = @"未同步";
        _status.textColor = [UIColor lightGrayColor];
        _status.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    else if (calendar.status == 1){
        _status.text = @"进行中";
        _status.textColor = [UIColor colorFromHexCode:@"0x5995f5"];
        _status.layer.borderColor = [UIColor colorFromHexCode:@"0x5995f5"].CGColor;
    }
    else if(calendar.status == 2){
        _status.text = @"已完成";
        _status.textColor = [UIColor whiteColor];
        _status.backgroundColor = [UIColor colorFromHexCode:@"0x5995f5"];
        _status.layer.borderColor = [UIColor colorFromHexCode:@"0x5995f5"].CGColor;
    }
    
    //紧急度
    if (calendar.emergency_status == 0) {
        _emergencyImg.hidden = YES;
    } else if (calendar.emergency_status == 1){
        _emergencyImg.hidden = NO;
        _emergencyImg.image = [UIImage imageNamed:@"calendar_emergency"];
    } else{
        _emergencyImg.hidden = NO;
        _emergencyImg.image = [UIImage imageNamed:@"calendar_dangerous"];
    }
}
/**
 *  计算文字尺寸
 *
 *  @param text    需要计算尺寸的文字
 *  @param font    文字的字体
 *  @param maxSize 文字的最大尺寸
 */
- (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}
@end
