//
//  FinishTaskView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskClickedDelegate.h"
//完结的
@interface FinishTaskView : UIView

@property (nonatomic, weak) id<TaskClickedDelegate> delegate;

@end
