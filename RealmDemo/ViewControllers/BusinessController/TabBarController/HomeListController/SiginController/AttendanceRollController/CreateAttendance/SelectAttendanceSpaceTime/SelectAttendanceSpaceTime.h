//
//  SelectAttendanceSpaceTime.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>

//选择上下班左右多少分钟提醒
typedef void(^SelectSpaceTimeBlock)(NSInteger selectDate);

@interface SelectAttendanceSpaceTime : UIViewController

@property (nonatomic, assign) NSInteger userSelectDate;
@property (nonatomic, copy) NSString *titleNameContent;//上面需要显示的名字
@property (nonatomic, copy) SelectSpaceTimeBlock selectSpaceTimeBlock;

@end
