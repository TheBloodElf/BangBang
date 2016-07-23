//
//  CalendarView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CalendarView.h"
#import "UserManager.h"

@interface CalendarView ()<RBQFetchedResultsControllerDelegate> {
    int _todayFinishCount;//今天完成数
    int _todayNoFinishCount;//今天未完成数
    int _weekFinishCount;//本周完成数
    int _weekNoFinishCount;//本周未完成数
    UserManager *_userManager;
    RBQFetchedResultsController *_calendarFetchedResultsController;
}

@end

@implementation CalendarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        _userManager = [UserManager manager];
        _calendarFetchedResultsController = [_userManager createCalendarFetchedResultsController];
        _calendarFetchedResultsController.delegate = self;
        //这里先创建两个按钮玩玩，具体的后面来做
        UIButton *todayFinish = [UIButton buttonWithType:UIButtonTypeSystem];
        todayFinish.frame = CGRectMake(0, 0, frame.size.width / 2, frame.size.height);
        [todayFinish setTitle:@"今日完成" forState:UIControlStateNormal];
        [todayFinish addTarget:self action:@selector(todayFinishClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:todayFinish];
        UIButton *weekFinish = [UIButton buttonWithType:UIButtonTypeSystem];
        weekFinish.frame = CGRectMake(frame.size.width / 2, 0, frame.size.width / 2, frame.size.height);
        [weekFinish setTitle:@"本周完成" forState:UIControlStateNormal];
        [weekFinish addTarget:self action:@selector(weekFinishClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:weekFinish];
        [self createCirlceUI];
    }
    return self;
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [self createCirlceUI];
}
//重新创建一次日程动画视图
- (void)createCirlceUI {
    _todayFinishCount = _todayNoFinishCount = _weekFinishCount = _weekNoFinishCount = 0;
    [self getCurrCount];
}
//获取这四个数字
- (void)getCurrCount {
    //先获取今天的
    NSDate *todayDate = [NSDate date];
    NSArray *todayArr = [_userManager getCalendarArrWithDate:todayDate];
    for (Calendar *tempCalendar in todayArr) {
        if(tempCalendar.repeat_type == 0) {//不是重复的就直接加
            if(tempCalendar.status == 1)
                _todayNoFinishCount ++;
            else
                _todayFinishCount ++;
        } else {//重复的要加上经过自己一天的
            if (tempCalendar.rrule.length > 0&&tempCalendar.r_begin_date_utc >0&&tempCalendar.r_end_date_utc>0) {
                Scheduler * s = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc/1000] andRule:tempCalendar.rrule];
                //得到所有的时间
                NSArray * occurences = [s occurencesBetween:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_end_date_utc/1000]];
                for (NSDate *tempDate in occurences) {
                    if(tempDate.year == todayDate.year && tempDate.month == todayDate.month && tempDate.day == todayDate.day) {
                        if([tempCalendar haveDeleteDate:tempDate]) {
                            continue;
                        } else if([tempCalendar haveFinishDate:tempDate]) {
                            _todayFinishCount ++;
                        } else {
                            _todayNoFinishCount ++;
                        }
                    }
                }
            }
        }
    }
    //再获取本周的 今天是本周的第几天
    int todayOfWeek = (int)todayDate.weekday;
    for (int i = 1 ;i <= 7; i ++) {
        NSDate *tempDate = [todayDate dateByAddingTimeInterval:(i - todayOfWeek) * 24 * 60 * 60];
        NSArray *tempArr = [_userManager getCalendarArrWithDate:tempDate];
        for (Calendar *tempCalendar in tempArr) {
            if(tempCalendar.repeat_type == 0) {//不是重复的就直接加
                if(tempCalendar.status == 1)
                    _weekNoFinishCount ++;
                else
                    _weekFinishCount ++;
            } else {//重复的要加上经过自己一天的
                if (tempCalendar.rrule.length > 0&&tempCalendar.r_begin_date_utc >0&&tempCalendar.r_end_date_utc>0) {
                    Scheduler * s = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.begindate_utc/1000] andRule:tempCalendar.rrule];
                    //得到所有的时间
                    NSArray * occurences = [s occurencesBetween:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_begin_date_utc/1000] andDate:[NSDate dateWithTimeIntervalSince1970:tempCalendar.r_end_date_utc/1000]];
                    for (NSDate *tempDateDate in occurences) {
                        if(tempDateDate.year == tempDate.year && tempDateDate.month == tempDate.month && tempDateDate.day == tempDate.day) {
                            if([tempCalendar haveDeleteDate:tempDate]) {
                                continue;
                            } else if([tempCalendar haveFinishDate:tempDate]) {
                                _weekFinishCount ++;
                            } else {
                                _weekNoFinishCount ++;
                            }
                        }
                    }
                }
            }
        }
    }
    
}
- (void)todayFinishClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(todayFinishCalendar)]) {
        [self.delegate todayFinishCalendar];
    }
}
- (void)weekFinishClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(weekFinishCalendar)]) {
        [self.delegate weekFinishCalendar];
    }
}
@end
