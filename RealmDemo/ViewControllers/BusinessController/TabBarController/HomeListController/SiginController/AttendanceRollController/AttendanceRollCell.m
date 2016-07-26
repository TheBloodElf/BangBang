//
//  AttendanceRollCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/28.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "AttendanceRollCell.h"

@interface AttendanceRollCell () {
    NSDictionary *_workDic;//数字日期映射关系
}

@property (weak, nonatomic) IBOutlet UIButton *delBtn;
@property (weak, nonatomic) IBOutlet UILabel *attendName;
@property (weak, nonatomic) IBOutlet UILabel *attendTime;
@property (weak, nonatomic) IBOutlet UILabel *attendAdress;


@end

@implementation AttendanceRollCell

- (void)awakeFromNib {
    [super awakeFromNib];
     _workDic = @{@"1":@"周一",@"2":@"周二",@"3":@"周三",@"4":@"周四",@"5":@"周五",@"6":@"周六",@"7":@"周日",};
    [self.delBtn addTarget:self action:@selector(delBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.delBtn.layer.cornerRadius = 5.f;
    self.delBtn.clipsToBounds = YES;
    // Initialization code
}
- (void)delBtnClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(attendanceRollDel:)]) {
        [self.delegate attendanceRollDel:self.data];
    }
}
- (void)dataDidChange {
    SiginRuleSet *_siginRuleSet = self.data;
    NSArray<PunchCardAddressSetting*> *_setting = _siginRuleSet.json_list_address_settings;
    self.attendName.text = _siginRuleSet.setting_name;
    //设置时间字符串
    NSMutableArray *workArr = [@[] mutableCopy];
    NSArray *array = [_siginRuleSet.work_day componentsSeparatedByString:@","];
    for (NSString *workDay in array)
        [workArr addObject:_workDic[workDay]];
    NSString * timeStr = [workArr componentsJoinedByString:@","];
    NSDate *upDate = [NSDate dateWithTimeIntervalSince1970:_siginRuleSet.start_work_time / 1000];
    NSDate *downDate = [NSDate dateWithTimeIntervalSince1970:_siginRuleSet.end_work_time / 1000];
    NSString *dateStr = [NSString stringWithFormat:@"%02ld:%02ld-%02ld:%02ld",upDate.hour,upDate.minute,downDate.hour,downDate.minute];
    NSString *allStr = [NSString stringWithFormat:@"时间: %@; %@",timeStr,dateStr];
    self.attendTime.text = allStr;
    NSMutableArray *adressArr = [@[] mutableCopy];
    for (PunchCardAddressSetting *setting in _setting) {
        [adressArr addObject:setting.name];
    }
    self.attendAdress.text = [NSString stringWithFormat:@"地址: %@",[adressArr componentsJoinedByString:@","]];
}

@end
