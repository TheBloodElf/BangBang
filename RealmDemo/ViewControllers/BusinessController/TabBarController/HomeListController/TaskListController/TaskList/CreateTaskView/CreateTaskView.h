//
//  CreateTaskView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskClickedDelegate.h"
//我委派的
@interface CreateTaskView : UIView

@property (nonatomic, weak) id<TaskClickedDelegate> delegate;

@end
