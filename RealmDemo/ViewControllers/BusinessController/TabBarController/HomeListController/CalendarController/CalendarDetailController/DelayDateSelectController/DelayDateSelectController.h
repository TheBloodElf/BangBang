//
//  DelayDateSelectController.h
//  RealmDemo
//
//  Created by Mac on 2016/11/15.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//日程推迟

@protocol DelayDateSelectDelegate <NSObject>

- (void)selectDelayDate:(int)second;
- (void)customSelectDate:(NSDate*)date;

@end

@interface DelayDateSelectController : UIViewController

@property (nonatomic, weak) id<DelayDateSelectDelegate> delegate;

@end
