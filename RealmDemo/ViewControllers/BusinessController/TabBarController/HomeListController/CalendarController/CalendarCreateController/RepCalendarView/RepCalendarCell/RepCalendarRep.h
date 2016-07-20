//
//  RepCalendarRep.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//重复性选择
@protocol RepCalendarRepDelegate <NSObject>
//重复性选择
- (void)RepCalendarSelectRep;

@end

@interface RepCalendarRep : UITableViewCell

@property (nonatomic, weak) id<RepCalendarRepDelegate> delegate;

@end
