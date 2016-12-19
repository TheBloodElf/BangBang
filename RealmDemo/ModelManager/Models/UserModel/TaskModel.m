//
//  TaskModel.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskModel.h"

@implementation TaskModel

+ (NSString*)primaryKey {
    return @"id";
}

- (NSString*)getCurrImageName {
    if(_status == 1)
        return @"task_add_icon";
    if(_status == 2)
        return @"task_going_icon";
    if(_status == 4)
        return @"task_wait_icon";
    if(_status == 6)
        return @"task_refuse_icon";
    if(_status == 7)
        return @"task_complte_icon";
    if(_status == 8)
        return @"task_end_icon";
    return @"";
}

@end
