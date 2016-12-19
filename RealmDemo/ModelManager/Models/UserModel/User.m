//
//  User.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "User.h"

@implementation User

MJExtensionCodingImplementation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _newMessage = YES;
        _ryDisturb = NO;
        _canPlayVoice = YES;
        _canPlayShake = YES;
        _ryDisturbBeginTime = [NSDate new];
        _ryDisturbEndTime = [NSDate new];
    }
    return self;
}

+ (NSString*)primaryKey {
    return @"user_guid";
}

@end
