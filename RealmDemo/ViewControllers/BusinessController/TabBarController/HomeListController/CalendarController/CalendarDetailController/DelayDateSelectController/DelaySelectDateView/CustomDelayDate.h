//
//  CustomDelayDate.h
//  RealmDemo
//
//  Created by Mac on 2016/11/15.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//自定义推迟时间
@protocol CustomDelayDelegate <NSObject>

- (void)customSelectDate:(NSDate*)date;
- (void)customCancle;

@end

@interface CustomDelayDate : UIView

@property (nonatomic, weak) id<CustomDelayDelegate> delegate;

@end
