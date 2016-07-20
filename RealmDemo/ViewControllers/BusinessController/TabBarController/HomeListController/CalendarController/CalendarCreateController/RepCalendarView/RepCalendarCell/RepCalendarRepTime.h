//
//  RepCalendarRepTime.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//重复开始结束时间选择
@protocol RepCalendarRepTimeDelegate <NSObject>

//重复开始时间
- (void)RepCalendarRepTimeBgein;
//重复结束时间
- (void)RepCalendarRepTimeEnd;

@end

@interface RepCalendarRepTime : UITableViewCell

@property (nonatomic, weak) id<RepCalendarRepTimeDelegate> delegate;

@end
