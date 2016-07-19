//
//  CalendarSelectAlertTime.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CalendarSelectTime)(int alertTime);

@interface CalendarSelectAlertTime : UIViewController

@property (nonatomic, copy )CalendarSelectTime calendarSelectTime;

@end
