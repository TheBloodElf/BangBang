//
//  SelectAttendanceTime.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/22.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SelectTimeBlock)(NSInteger selectDate);

@protocol SelectAttendanceTimeDelegate <NSObject>

- (void)selectAttendanceTime:(NSInteger)selectDate;

@end

//选择时间
@interface SelectAttendanceTime : UIViewController

@property (nonatomic, copy) SelectTimeBlock selectTimeBlock;
@property (nonatomic, weak) id<SelectAttendanceTimeDelegate> delegate;

@end
