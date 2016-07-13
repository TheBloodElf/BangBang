//
//  DataCache.m
//  fadein
//
//  Created by Maverick on 15/12/31.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import "DataCache.h"

@implementation DataCache

+ (void)setCache:(id)data forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)loadCache:(NSString *)key {
    return [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] valueForKey:key]];
}

@end
