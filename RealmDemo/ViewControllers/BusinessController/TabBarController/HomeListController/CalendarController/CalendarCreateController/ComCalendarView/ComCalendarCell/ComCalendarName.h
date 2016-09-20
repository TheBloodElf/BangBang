//
//  ComCalendarName.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//名称

@protocol ComCalendarNameDelegate <NSObject>
//名称超长
- (void)comCalendarNameLengthOver;

@end

@interface ComCalendarName : UITableViewCell

@property (nonatomic, weak) id<ComCalendarNameDelegate> delegate;

@end
