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
    for (NSString *timeStr in timeArr) {
        //直接计算1970距离现在多少天 这样更快
        if((int)(date.timeIntervalSince1970 / (24 * 60 * 60)) == (int)(timeStr.doubleValue / (24 * 60 * 60)))
            return YES;
    }
    return NO;
}
- (BOOL)haveFinishDate:(NSDate*)date {
    NSArray *timeArr = [self.finished_dates componentsSeparatedByString:@","];
    if(timeArr.count == 0) return NO;
    for (NSString *timeStr in timeArr) {
        //直接计算1970距离现在多少天 这样更快
        if((int)(date.timeIntervalSince1970 / (24 * 60 * 60)) == (int)(timeStr.doubleValue / (24 * 60 * 60)))
            return YES;
    }
    return NO;
}
@end
