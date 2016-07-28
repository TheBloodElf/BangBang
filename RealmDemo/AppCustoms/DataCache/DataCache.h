//
//  DataCache.h
//  fadein
//
//  Created by Maverick on 15/12/31.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCache : NSObject

+ (void)setCache:(id)data forKey:(NSString *)key;

+ (id)loadCache:(NSString *)key;

@end
