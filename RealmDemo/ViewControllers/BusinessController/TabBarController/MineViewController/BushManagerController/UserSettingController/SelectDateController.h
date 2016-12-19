//
//  SelectDateController.h
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectDateBlock)(NSDate *selectDate);
//时间选择器
@interface SelectDateController : UIViewController

@property (nonatomic, strong) NSDate *needShowDate;//当前需要显示的时间
@property (nonatomic, copy  ) SelectDateBlock selectDateBlock;
@property (nonatomic, assign) UIDatePickerMode datePickerMode;

@end
