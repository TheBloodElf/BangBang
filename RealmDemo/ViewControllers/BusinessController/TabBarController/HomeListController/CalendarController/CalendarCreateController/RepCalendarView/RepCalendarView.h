//
//  RepCalendarView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//例行事务

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

@interface RepCalendarView : UIView

@property (nonatomic,  weak) id<RepCalendarViewDelegate> delegate;
@property (nonatomic, assign) BOOL isDetail;//是否在详情页面，用户不能操作
@property (nonatomic, assign) BOOL isEdit;//是否在编辑界面，不能修改分享人

@end
