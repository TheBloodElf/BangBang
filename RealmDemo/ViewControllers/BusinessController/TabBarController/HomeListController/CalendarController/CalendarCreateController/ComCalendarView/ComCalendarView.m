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

@interface ComCalendarView ()<UITableViewDelegate,UITableViewDataSource,ComCalendarTimeDelegate,ComCalendarNameDelegate,ComCalendarInstructionDelegate,ComCalendarAdressDelegate> {
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
        case 5:
            height = [_calendar.member_names textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 100 - 25, 1000)].height + 10;
            if(height < 50)
                height = 50;
            break;//分享
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
    if (indexPath.row == 0) {
        ComCalendarName *name = (id)cell;
        name.data = _calendar;
        name.delegate = self;
    } else if (indexPath.row == 1) {
        ComCalendarTime *time = (id)cell;
        time.data = _calendar;
        time.delegate = self;
    } else if (indexPath.row == 2) {
        cell.data = _calendar;
    } else if (indexPath.row == 3) {
        ComCalendarDetail *comCalendarDetail = (id)cell;
        comCalendarDetail.titleLabel.text = @"事前提醒:";
        if(_calendar.alert_minutes_before == 0)
            comCalendarDetail.detailTextView.text = @"无";
        else
            comCalendarDetail.detailTextView.text = [NSString stringWithFormat:@"%d分钟",_calendar.alert_minutes_before];
    } else if (indexPath.row == 4) {
        ComCalendarDetail *comCalendarDetail = (id)cell;
        comCalendarDetail.titleLabel.text = @"事后提醒:";
        if(_calendar.alert_minutes_after == 0)
            comCalendarDetail.detailTextView.text = @"无";
        else
            comCalendarDetail.detailTextView.text = [NSString stringWithFormat:@"%d分钟",_calendar.alert_minutes_after];
    } else if (indexPath.row == 5) {
        ComCalendarDetail *comCalendarDetail = (id)cell;
        comCalendarDetail.titleLabel.text = @"分享给:";
        comCalendarDetail.detailTextView.text = [NSString isBlank:_calendar.member_names] ? @"无": _calendar.member_names;
        if(![NSString isBlank:_calendar.member_names]) {
            comCalendarDetail.detailTextViewHeight.constant = [_calendar.member_names textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 100 - 25, 1000)].height;
        }
    } else if (indexPath.row == 6) {//地址
        ComCalendarAdress *comCalendarInstructionCell = (id)cell;
        comCalendarInstructionCell.delegate = self;
        comCalendarInstructionCell.data = _calendar;
    } else if (indexPath.row == 7) {//详情
        ComCalendarInstruction *comCalendarInstructionCell = (id)cell;
        comCalendarInstructionCell.delegate = self;
        comCalendarInstructionCell.data = _calendar;
    }
    //取消点击效果 #BANG392
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#pragma mark --
#pragma mark -- ComCalendarAdressDelegate
- (void)comCalendarAdressOverLength {
    [self showMessageTips:@"地址不能超过30字符"];
}
#pragma mark -- 
#pragma mark -- ComCalendarInstructionDelegate
- (void)comCalendarInstructionOverLength {
    [self showMessageTips:@"详情不能超过500字符"];
}
#pragma mark -- 
#pragma mark -- ComCalendarNameDelegate
//名称超长
- (void)comCalendarNameLengthOver {
    [self showMessageTips:@"名称不能超过30字符"];
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
