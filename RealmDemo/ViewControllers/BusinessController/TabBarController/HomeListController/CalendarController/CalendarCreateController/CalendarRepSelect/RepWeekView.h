//
//  RepWeekView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepWeekView : UIView

//设置默认显示的规则
- (void)setEKRecurrenceRule:(EKRecurrenceRule*)eKRecurrenceRule;
- (EKRecurrenceRule*)eKRecurrenceRule;

@end
