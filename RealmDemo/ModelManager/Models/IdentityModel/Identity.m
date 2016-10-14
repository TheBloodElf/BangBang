//
//  Identity.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "Identity.h"

@implementation Identity

MJExtensionCodingImplementation

- (instancetype)init
{
    self = [super init];
    if (self) {
        _newMessage = YES;
        _firstUseSoft = YES;
        _ryDisturb = NO;
        _canPlayVoice = YES;
        _canPlayShake = YES;
        _bootOfUse = NO;
        _ryDisturbBeginTime = [NSDate new];
        _ryDisturbEndTime = [NSDate new];
    }
    return self;
}

@end
