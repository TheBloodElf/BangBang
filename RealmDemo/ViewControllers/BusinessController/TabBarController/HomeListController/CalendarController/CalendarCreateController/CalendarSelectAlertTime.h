//
//  CalendarSelectAlertTime.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//单位分钟
typedef void(^CalendarSelectTime)(int alertTime);

@interface CalendarSelectAlertTime : UIViewController

@property (nonatomic, assign) int userSelectTime;//用户已经选择的时间 单位分钟
@property (nonatomic, copy  ) CalendarSelectTime calendarSelectTime;

@end
