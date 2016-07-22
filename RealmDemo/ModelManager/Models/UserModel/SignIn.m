//
//  SignIn.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/21.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SignIn.h"

@implementation SignIn

+ (NSString*)primaryKey {
    return @"id";
}
/**
 *  类型；0-上班；1-下班；2-外勤；3-其他
 */
- (NSString*)categoryStr {
    if (_category == 0)
        return @"上班";
    else if (_category == 1)
        return @"下班";
    else if (_category == 2)
        return @"外勤";
    return @"其他";
}
@end
