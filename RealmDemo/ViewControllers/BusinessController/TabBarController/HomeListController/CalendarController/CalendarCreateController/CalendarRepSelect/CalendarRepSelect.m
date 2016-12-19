//
//  CalendarRepSelect.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CalendarRepSelect.h"
#import "RepDayView.h"
#import "RepWeekView.h"
#import "RepMonthView.h"
#import "RepYearView.h"

@interface CalendarRepSelect () {
    EKRecurrenceRule *_ekRecurrenceRule;
    RepDayView *_repDayView;//按天
    RepWeekView *_repWeekView;//按周
    RepMonthView *_repMonthView;//按月
    RepYearView *_repYearView;//按年
    int _currIndex;//当前是哪一个分类
}

@property (weak, nonatomic) IBOutlet UIScrollView *centerView;//中间选项视图

@end

@implementation CalendarRepSelect

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat width = _centerView.frame.size.width;
    CGFloat height = _centerView.frame.size.height;
    _repDayView = [[NSBundle mainBundle] loadNibNamed:@"RepDayView" owner:nil options:nil][0];
    _repDayView.frame = CGRectMake(0, 0, width, height);
    [_centerView addSubview:_repDayView];
    _repWeekView = [[NSBundle mainBundle] loadNibNamed:@"RepWeekView" owner:nil options:nil][0];
    _repWeekView.frame = CGRectMake(width, 0, width, height);
    [_centerView addSubview:_repWeekView];
    _repMonthView = [[NSBundle mainBundle] loadNibNamed:@"RepMonthView" owner:nil options:nil][0];
    _repMonthView.frame = CGRectMake(2 * width, 0, width, height);
    [_centerView addSubview:_repMonthView];
    _repYearView = [[NSBundle mainBundle] loadNibNamed:@"RepYearView" owner:nil options:nil][0];
    _repYearView.frame = CGRectMake(3 * width, 0, width, height);
    [_centerView addSubview:_repYearView];
    _centerView.contentSize = CGSizeMake(4 * width, height);
    //判断当前用户的重复性类型 初始化对应视图默认显示的规则
    _currIndex = _userSelectEKRecurrenceRule.frequency;
    //让对应类型选择按钮被选中
    for (int i = 0; i < 4; i ++) {
        UIButton *btn = [self.view viewWithTag:1000 + i];
        btn.selected = NO;
    }
    UIButton *btn = [self.view viewWithTag:1000 + _currIndex];
    btn.selected = YES;
    if(_currIndex == 0)
        [_repDayView setEKRecurrenceRule:_userSelectEKRecurrenceRule];
    if(_currIndex == 1)
        [_repWeekView setEKRecurrenceRule:_userSelectEKRecurrenceRule];
    if(_currIndex == 2)
        [_repMonthView setEKRecurrenceRule:_userSelectEKRecurrenceRule];
    if(_currIndex == 3)
        [_repYearView setEKRecurrenceRule:_userSelectEKRecurrenceRule];
    [_centerView setContentOffset:CGPointMake(_currIndex * _centerView.frame.size.width, 0) animated:NO];
}

- (IBAction)typeClicked:(UIButton*)sender {
    _currIndex = (int)sender.tag - 1000;
    for (int i = 0; i < 4; i ++) {
        UIButton *btn = [self.view viewWithTag:1000 + i];
        btn.selected = NO;
    }
    sender.selected = YES;
    [self.view endEditing:YES];
    [_centerView setContentOffset:CGPointMake(_currIndex * _centerView.frame.size.width, 0) animated:NO];
}

- (IBAction)okClicked:(id)sender {
    EKRecurrenceRule *rule = nil;
    if(_currIndex == 0) {
        rule = [_repDayView eKRecurrenceRule];
    } else if (_currIndex == 1) {
        rule = [_repWeekView eKRecurrenceRule];
    } else if (_currIndex == 2) {
        rule = [_repMonthView eKRecurrenceRule];
    } else if (_currIndex == 3) {
        rule = [_repYearView eKRecurrenceRule];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(calendarRepSelect:)]) {
        [self.delegate calendarRepSelect:rule];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)cancleClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
