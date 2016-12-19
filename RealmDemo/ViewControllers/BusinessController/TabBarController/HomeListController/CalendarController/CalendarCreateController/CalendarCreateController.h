//
//  CalendarCreateController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//创建日程
@interface CalendarCreateController : UIViewController
//日程时间显示这个时间 没有就显示当前时间
@property (nonatomic, strong) NSDate *createDate;

@end
