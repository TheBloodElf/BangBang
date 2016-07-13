//
//  HomeListTopView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HomeListTopDelegate <NSObject>
//今天完成日程被点击
- (void)todayFinishCalendar;
//本周完成日程被点击
- (void)weekFinishCalendar;
//我委派的任务被点击
- (void)createTaskClicked;
//我负责的任务被点击
- (void)chargeTaskClicked;

@end

@interface HomeListTopView : UIView

@property (nonatomic, weak) id<HomeListTopDelegate> delegate;

@end
