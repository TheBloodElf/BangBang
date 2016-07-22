//
//  AttendanceRollCell.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/28.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SiginRuleSet.h"
#import "PunchCardAddressSetting.h"

@protocol AttendanceRollCellDelegate <NSObject>

- (void)attendanceRollDel:(SiginRuleSet*)set;

@end

@interface AttendanceRollCell : UITableViewCell


@property (nonatomic, weak) id<AttendanceRollCellDelegate> delegate;

@end
