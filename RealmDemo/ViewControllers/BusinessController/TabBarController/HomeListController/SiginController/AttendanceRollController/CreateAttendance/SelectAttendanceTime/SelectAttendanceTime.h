//
//  SelectAttendanceTime.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/22.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
//单位毫秒
typedef void(^SelectTimeBlock)(int64_t selectDate);

@protocol SelectAttendanceTimeDelegate <NSObject>

- (void)selectAttendanceTime:(int64_t)selectDate;

@end

//选择时间
@interface SelectAttendanceTime : UIViewController

@property (nonatomic, assign) int64_t userSelectDate;
@property (nonatomic, copy) SelectTimeBlock selectTimeBlock;
@property (nonatomic, weak) id<SelectAttendanceTimeDelegate> delegate;

@end
