//
//  MError.m
//  fadein
//
//  Created by Maverick on 15/12/27.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import "MError.h"

@implementation MError

- (instancetype)initWithCode:(NSInteger)code statsMsg:(NSString*)statsMsg
{
    if(self = [super init]) {
        self.statsCode = code;
        self.statsMsg = statsMsg;
    }
    return self;
}

+ (MError *)error:(HTTP_ERROR_CODE)code {
    MError *error = [MError new];
    error.statsCode = code;
    return error;
}

- (NSString *)errorTips {
    NSString *tips = nil;
    
    switch (_statsCode) {
        case 10000: tips = @"asdasdasd"; break;
        case 10001: tips = @"asdasdasd"; break;
        default:
            break;
    }
    
    return tips;
}

@end
