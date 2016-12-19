//
//  CalendarRepEditView.h
//  RealmDemo
//
//  Created by Mac on 2016/12/7.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//例行事务编辑 不能选择分享人

@protocol RepCalendarViewDelegate <NSObject>
//例行开始时间
- (void)RepCalendarViewBegin;
//例行结束时间
- (void)RepCalendarViewEnd;
//重复性选择
- (void)RepCalendarSelectRep;
//例行重复时间开始
- (void)RepCalendarViewRepBegin;
//例行重复时间结束
- (void)RepCalendarViewRepEnd;
//事前提醒
- (void)ComCanendarAlertBefore;
//事后提醒
- (void)ComCanendarAlertAfter;
//分享
- (void)ComCanendarShare;

@end

@interface CalendarRepEditView : UIView

@property (nonatomic,  weak) id<RepCalendarViewDelegate> delegate;

@end
