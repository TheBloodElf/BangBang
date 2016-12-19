//
//  RepDayView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//周期设置天视图
@interface RepDayView : UIView

//设置默认显示的规则
- (void)setEKRecurrenceRule:(EKRecurrenceRule*)eKRecurrenceRule;
- (EKRecurrenceRule*)eKRecurrenceRule;

@end
