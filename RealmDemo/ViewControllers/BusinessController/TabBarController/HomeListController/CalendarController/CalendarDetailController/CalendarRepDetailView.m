//
//  CalendarRepDetailView.m
//  RealmDemo
//
//  Created by Mac on 2016/12/7.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CalendarRepDetailView.h"
#import "Calendar.h"
#import "RepCalendarTime.h"
#import "ComCalendarName.h"
#import "ComCalendarExigence.h"
#import "RepCalendarRep.h"
#import "ComCalendarAdress.h"
#import "ComCalendarDetail.h"
#import "ComCalendarInstruction.h"
#import "RepCalendarRepTime.h"

@interface CalendarRepDetailView ()<UITableViewDelegate,UITableViewDataSource,RepCalendarTimeDelegate,RepCalendarRepDelegate,RepCalendarRepTimeDelegate,ComCalendarNameDelegate,ComCalendarInstructionDelegate,ComCalendarAdressDelegate> {
    Calendar *_calendar;
    UITableView *_tableView;
}

@end

@implementation CalendarRepDetailView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarName" bundle:nil] forCellReuseIdentifier:@"ComCalendarName"];
        [_tableView registerNib:[UINib nibWithNibName:@"RepCalendarTime" bundle:nil] forCellReuseIdentifier:@"RepCalendarTime"];
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarExigence" bundle:nil] forCellReuseIdentifier:@"ComCalendarExigence"];
        [_tableView registerNib:[UINib nibWithNibName:@"RepCalendarRep" bundle:nil] forCellReuseIdentifier:@"RepCalendarRep"];
        [_tableView registerNib:[UINib nibWithNibName:@"RepCalendarRepTime" bundle:nil] forCellReuseIdentifier:@"RepCalendarRepTime"];
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarDetail" bundle:nil] forCellReuseIdentifier:@"ComCalendarDetail"];
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarAdress" bundle:nil] forCellReuseIdentifier:@"ComCalendarAdress"];
        [_tableView registerNib:[UINib nibWithNibName:@"ComCalendarInstruction" bundle:nil] forCellReuseIdentifier:@"ComCalendarInstruction"];
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
    }
    return self;
}
-(void)dataDidChange {
    _calendar = self.data;
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- RepCalendarTimeDelegate
//开始事件被点击
- (void)repCalendarTimeBeginTime {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarViewBegin)]) {
        [self.delegate RepCalendarViewBegin];
    }
}
//结束事件被点击
- (void)repCalendarTimeEndTime {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarViewEnd)]) {
        [self.delegate RepCalendarViewEnd];
    }
}
//全天被点击
- (void)repCalendarTimeAllDay {
    _calendar.is_allday = !_calendar.is_allday;
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- RepCalendarRepDelegate
//重复性选择
- (void)RepCalendarSelectRep {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarSelectRep)]) {
        [self.delegate RepCalendarSelectRep];
    }
}
#pragma mark --
#pragma mark -- RepCalendarRepTimeDelegate
//重复开始时间
- (void)RepCalendarRepTimeBgein {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarViewRepBegin)]) {
        [self.delegate RepCalendarViewRepBegin];
    }
}
//重复结束时间
- (void)RepCalendarRepTimeEnd {
    if(self.delegate && [self.delegate respondsToSelector:@selector(RepCalendarViewRepEnd)]) {
        [self.delegate RepCalendarViewRepEnd];
    }
}
#pragma mark --
#pragma mark -- ComCalendarAdressDelegate
- (void)comCalendarAdressOverLength {
    [self showMessageTips:@"地址不能超过30字符"];
}
#pragma mark --
#pragma mark -- ComCalendarNameDelegate
//名称超长
- (void)comCalendarNameLengthOver {
    [self showMessageTips:@"名称不能超过30"];
}
#pragma mark --
#pragma mark -- ComCalendarInstructionDelegate
- (void)comCalendarInstructionOverLength {
    [self showMessageTips:@"详情不能超过500字符"];
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
        case 7:
            height = [_calendar.member_names textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 100 - 25, 1000)].height + 10;
            if(height < 50)
                height = 50;
            break;//分享
        case 8: height = 50; break;
        default: height = 100; break;
    }
    return height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if(indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarName" forIndexPath:indexPath];
    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RepCalendarTime" forIndexPath:indexPath];
    } else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarExigence" forIndexPath:indexPath];
    } else if(indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RepCalendarRep" forIndexPath:indexPath];
    } else if(indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"RepCalendarRepTime" forIndexPath:indexPath];
    } else if (indexPath.row == 5 || indexPath.row == 6 || indexPath.row == 7) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarDetail" forIndexPath:indexPath];
    } else if(indexPath.row == 8) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarAdress" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ComCalendarInstruction" forIndexPath:indexPath];
    }
    if (indexPath.row == 0) {
        ComCalendarName *name = (id)cell;
        name.data = _calendar;
        name.delegate = self;
    } else if (indexPath.row == 1) {
        RepCalendarTime *time = (id)cell;
        time.data = _calendar;
        time.delegate = self;
    } else if (indexPath.row == 2) {
        cell.data = _calendar;
    } else if (indexPath.row == 3) {
        RepCalendarRep *rep = (id)cell;
        rep.data = _calendar;
        rep.delegate = self;
    } else if (indexPath.row == 4) {
        RepCalendarRepTime *rep = (id)cell;
        rep.data = _calendar;
        rep.delegate = self;
    } else if (indexPath.row == 5) {
        ComCalendarDetail *comCalendarDetail = (id)cell;
        comCalendarDetail.titleLabel.text = @"事前提醒:";
        if(_calendar.alert_minutes_before == 0)
            comCalendarDetail.detailTextView.text = @"无";
        else
            comCalendarDetail.detailTextView.text = [NSString stringWithFormat:@"%d分钟",_calendar.alert_minutes_before];
    } else if (indexPath.row == 6) {
        ComCalendarDetail *comCalendarDetail = (id)cell;
        comCalendarDetail.titleLabel.text = @"事后提醒:";
        if(_calendar.alert_minutes_after == 0)
            comCalendarDetail.detailTextView.text = @"无";
        else
            comCalendarDetail.detailTextView.text = [NSString stringWithFormat:@"%d分钟",_calendar.alert_minutes_after];
    } else if (indexPath.row == 7) {
        ComCalendarDetail *comCalendarDetail = (id)cell;
        comCalendarDetail.titleLabel.text = @"分享给:";
        comCalendarDetail.detailTextView.text = [NSString isBlank:_calendar.member_names] ? @"无": _calendar.member_names;
        if(![NSString isBlank:_calendar.member_names]) {
            comCalendarDetail.detailTextViewHeight.constant = [_calendar.member_names textSizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 100 - 25, 1000)].height;
        }
    } else if(indexPath.row == 8){//地点
        ComCalendarAdress *comCalendarInstructionCell = (id)cell;
        comCalendarInstructionCell.delegate = self;
        comCalendarInstructionCell.data = _calendar;
    } else if(indexPath.row == 9){//详情
        ComCalendarInstruction *comCalendarInstructionCell = (id)cell;
        comCalendarInstructionCell.delegate = self;
        comCalendarInstructionCell.data = _calendar;
    }
    
    cell.userInteractionEnabled = NO;
    //取消点击效果 #BANG392
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 5) {//提醒时间
        if(self.delegate && [self.delegate respondsToSelector:@selector(ComCanendarAlertBefore)]) {
            [self.delegate ComCanendarAlertBefore];
        }
    } else if (indexPath.row == 6) {//提醒时间
        if(self.delegate && [self.delegate respondsToSelector:@selector(ComCanendarAlertAfter)]) {
            [self.delegate ComCanendarAlertAfter];
        }
    } else if(indexPath.row == 7) {//分享
        if(self.delegate && [self.delegate respondsToSelector:@selector(ComCanendarShare)]) {
            [self.delegate ComCanendarShare];
        }
    }
}
@end
