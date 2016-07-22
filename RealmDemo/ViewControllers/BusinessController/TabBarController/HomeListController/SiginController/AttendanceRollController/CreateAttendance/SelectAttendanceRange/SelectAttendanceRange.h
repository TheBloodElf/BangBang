//
//  SelectAttendanceRange.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/22.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
//选择考勤规则误差范围

@protocol SelectAttendanceRangeDelegate <NSObject>

- (void)selectAttendanceRange:(NSInteger)range;

@end

@interface SelectAttendanceRange : UIViewController

@property (nonatomic, weak) id<SelectAttendanceRangeDelegate> delegate;

@end
