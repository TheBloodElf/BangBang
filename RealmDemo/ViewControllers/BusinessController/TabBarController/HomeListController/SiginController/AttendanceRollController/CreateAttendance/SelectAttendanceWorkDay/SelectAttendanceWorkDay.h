//
//  SelectAttendanceWorkDay.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
//选择工作日

@protocol SelectAttendanceWorkDayDelegate <NSObject>

- (void)selectAttendanceWorkDay:(NSArray<NSNumber*>*) workDays;

@end

@interface SelectAttendanceWorkDay : UIViewController

@property (nonatomic, strong) NSArray<NSNumber*> *userSelectDays;
@property (nonatomic, weak) id<SelectAttendanceWorkDayDelegate> delegate;

@end
