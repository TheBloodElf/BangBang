//
//  SelectDelayDateView.h
//  RealmDemo
//
//  Created by Mac on 2016/11/15.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectDelayDateDelegate <NSObject>

- (void)selectDelayDate:(int)second;
- (void)selectCustom;

@end
//选择推迟时间
@interface SelectDelayDateView : UIView

@property (nonatomic, weak) id<SelectDelayDateDelegate> delegate;

@end
