//
//  Calendar.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "Calendar.h"

@implementation Calendar

+ (NSString*)primaryKey {
    return @"id";
}
+ (Calendar*)copyFromCalendar:(Calendar*)calendar {
    Calendar *tempCalendar = [Calendar new];
    tempCalendar.id = calendar.id;
    tempCalendar.company_no = calendar.company_no;
    tempCalendar.event_name = calendar.event_name;
    tempCalendar.descriptionStr = calendar.descriptionStr;
    tempCalendar.address = calendar.address;
    tempCalendar.begindate_utc = calendar.begindate_utc;
    tempCalendar.enddate_utc = calendar.enddate_utc;
    tempCalendar.is_allday = calendar.is_allday;
    tempCalendar.app_guid = calendar.app_guid;
    tempCalendar.target_id = calendar.target_id;
    tempCalendar.repeat_type = calendar.repeat_type;
    tempCalendar.is_alert = calendar.is_alert;
    tempCalendar.alert_minutes_before = calendar.alert_minutes_before;
    tempCalendar.alert_minutes_after = calendar.alert_minutes_after;
    tempCalendar.user_guid = calendar.user_guid;
    tempCalendar.created_by = calendar.created_by;
    tempCalendar.createdon_utc = calendar.createdon_utc;
    tempCalendar.updated_by = calendar.updated_by;
    tempCalendar.updatedon_utc = calendar.updatedon_utc;
    tempCalendar.status = calendar.status;
    tempCalendar.finishedon_utc = calendar.finishedon_utc;
    tempCalendar.rrule = calendar.rrule;
    tempCalendar.rdate = calendar.rdate;
    tempCalendar.emergency_status = calendar.emergency_status;
    tempCalendar.deleted_dates = calendar.deleted_dates;
    tempCalendar.finished_dates = calendar.finished_dates;
    tempCalendar.r_begin_date_utc = calendar.r_begin_date_utc;
    tempCalendar.r_end_date_utc = calendar.r_end_date_utc;
    tempCalendar.is_over_day = calendar.is_over_day;
    tempCalendar.members = calendar.members;
    tempCalendar.member_names = calendar.member_names;
    tempCalendar.event_guid = calendar.event_guid;
    tempCalendar.creator_name = calendar.creator_name;
    return tempCalendar;
}
- (BOOL)haveDeleteDate:(NSDate*)date {
    NSArray *timeArr = [self.deleted_dates componentsSeparatedByString:@","];
    for (NSString *timeStr in timeArr) {
        NSDate *startTimeTemp = [NSDate dateWithTimeIntervalSince1970:timeStr.integerValue / 1000];
        NSString *key = [NSString stringWithFormat:@"%ld年%02ld月%02ld日",startTimeTemp.year,startTimeTemp.month,startTimeTemp.day];
        NSString *comeKey = [NSString stringWithFormat:@"%ld年%02ld月%02ld日",date.year,date.month,date.day];
        if([key isEqualToString:comeKey])
            return YES;
    }
    return NO;
}
- (BOOL)haveFinishDate:(NSDate*)date {
    NSArray *timeArr = [self.finished_dates componentsSeparatedByString:@","];
    for (NSString *timeStr in timeArr) {
        NSDate *startTimeTemp = [NSDate dateWithTimeIntervalSince1970:timeStr.integerValue / 1000];
        NSString *key = [NSString stringWithFormat:@"%ld年%02ld月%02ld日",startTimeTemp.year,startTimeTemp.month,startTimeTemp.day];
        NSString *comeKey = [NSString stringWithFormat:@"%ld年%02ld月%02ld日",date.year,date.month,date.day];
        if([key isEqualToString:comeKey])
            return YES;
    }
    return NO;
}
@end
