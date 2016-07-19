//
//  ComCalendarView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarView.h"
#import "Calendar.h"
#import "ComCalendarName.h"
#import "ComCalendarTime.h"
#import "ComCalendarExigence.h"
#import "ComCalendarDetail.h"
#import "ComCalendarAdress.h"
#import "ComCalendarInstruction.h"

@interface ComCalendarView ()<UITableViewDelegate,UITableViewDataSource,ComCalendarTimeDelegate> {
    Calendar *_calendar;
    UITableView *_tableView;
}

@end

@implementation ComCalendarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarName" bundle:nil] forCellReuseIdentifier:@"ComCalendarName"];
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarTime" bundle:nil] forCellReuseIdentifier:@"ComCalendarTime"];
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarExigence" bundle:nil] forCellReuseIdentifier:@"ComCalendarExigence"];
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarDetail" bundle:nil] forCellReuseIdentifier:@"ComCalendarDetail"];
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarAdress" bundle:nil] forCellReuseIdentifier:@"ComCalendarAdress"];
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarInstruction" bundle:nil] forCellReuseIdentifier:@"ComCalendarInstruction"];
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
    }
    return self;
}
- (void)dataDidChange {
    _calendar = self.data;
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    switch (indexPath.row) {
        case 0: height = 50; break;
        case 1: height = 88; break;
        case 2: height = 50; break;
        case 3: height = 50; break;
        case 4: height = 50; break;
        case 5: height = 50; break;
        case 6: height = 50; break;
        default: height = 100; break;
    }
    return height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if(indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarName" forIndexPath:indexPath];
    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarTime" forIndexPath:indexPath];
    } else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarExigence" forIndexPath:indexPath];
    } else if (indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarDetail" forIndexPath:indexPath];
    } else if(indexPath.row == 6) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarAdress" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarInstruction" forIndexPath:indexPath];
    }
    
    if (indexPath.row == 1) {
        ComCalendarTime *time = (id)cell;
        time.data = _calendar;
        time.delegate = self;
    } else if (indexPath.row == 3) {
        ComCalendarDetail *comCalendarDetail = (id)cell;
        comCalendarDetail.titleLabel.text = @"事前提醒:";
        if(_calendar.alert_minutes_before == 0)
            comCalendarDetail.detailLabel.text = @"无";
        else
            comCalendarDetail.detailLabel.text = [NSString stringWithFormat:@"%d分钟",_calendar.alert_minutes_before];
    } else if (indexPath.row == 4) {
        ComCalendarDetail *comCalendarDetail = (id)cell;
        comCalendarDetail.titleLabel.text = @"事后提醒:";
        if(_calendar.alert_minutes_after == 0)
            comCalendarDetail.detailLabel.text = @"无";
        else
            comCalendarDetail.detailLabel.text = [NSString stringWithFormat:@"%d分钟",_calendar.alert_minutes_after];
    } else if (indexPath.row == 5) {
        ComCalendarDetail *comCalendarDetail = (id)cell;
        comCalendarDetail.titleLabel.text = @"分享给:";
        comCalendarDetail.detailLabel.text = _calendar.member_names ?: @"无";
    } else {
        cell.data = _calendar;
    }
    
    return cell;
}
#pragma mark -- 
#pragma mark -- ComCalendarTimeDelegate
//开始事件被点击
- (void)comCalendarTimeBeginTime {
    if(self.delegate && [self.delegate respondsToSelector:@selector(ComCalendarViewBegin)]) {
        [self.delegate ComCalendarViewBegin];
    }
}
//结束事件被点击
- (void)comCalendarTimeEndTime {
    if(self.delegate && [self.delegate respondsToSelector:@selector(ComCalendarViewEnd)]) {
        [self.delegate ComCalendarViewEnd];
    }
}
//全天被点击
- (void)comCalendarTimeAllDay {
    _calendar.is_allday = !_calendar.is_allday;
    [_tableView reloadData];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 3) {//提醒时间
        if(self.delegate && [self.delegate respondsToSelector:@selector(ComCanendarAlertBefore)]) {
            [self.delegate ComCanendarAlertBefore];
        }
    } else if (indexPath.row == 4) {//提醒时间
        if(self.delegate && [self.delegate respondsToSelector:@selector(ComCanendarAlertAfter)]) {
            [self.delegate ComCanendarAlertAfter];
        }
    } else if(indexPath.row == 5) {//分享
        if(self.delegate && [self.delegate respondsToSelector:@selector(ComCanendarShare)]) {
            [self.delegate ComCanendarShare];
        }
    }
}
@end
