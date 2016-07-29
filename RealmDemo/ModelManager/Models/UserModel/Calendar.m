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
