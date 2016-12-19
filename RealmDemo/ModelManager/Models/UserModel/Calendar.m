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
    if(timeArr.count == 0) return NO;
    //依次取出"秒"时间字符串 和参数判断
    for (NSString *timeStr in timeArr) {
        NSDate *currDate = [NSDate dateWithTimeIntervalSince1970:timeStr.doubleValue];
//        NSLog(@"%d-%d-%d",currDate.year,currDate.month,currDate.day);
//        NSLog(@"%d-%d-%d",date.year,date.month,date.day);
        if(currDate.year == date.year)
            if(currDate.month == date.month)
                if(currDate.day == date.day)
                    return YES;
    }
    return NO;
}
- (BOOL)haveFinishDate:(NSDate*)date {
    NSArray *timeArr = [self.finished_dates componentsSeparatedByString:@","];
    if(timeArr.count == 0) return NO;
    for (NSString *timeStr in timeArr) {
        NSDate *currDate = [NSDate dateWithTimeIntervalSince1970:timeStr.doubleValue];
        if(currDate.year == date.year)
            if(currDate.month == date.month)
                if(currDate.day == date.day)
                    return YES;
    }
    return NO;
}
@end
