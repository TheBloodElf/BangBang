//
//  AppCustoms.m
//  fadein
//
//  Created by Maverick on 16/1/26.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "AppCustoms.h"



@implementation AppCustoms


#pragma mark -
#pragma mark - SINGLETON

static AppCustoms * __singleton__;

+ (AppCustoms *)customs {
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{ __singleton__ = [[[self class] alloc] init]; } );
    return __singleton__;
}


#pragma mark -
#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
       
    }
    return self;
}

@end
