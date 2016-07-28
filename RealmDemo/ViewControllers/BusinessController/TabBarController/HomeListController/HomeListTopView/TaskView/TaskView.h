//
//  TaskView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaskViewDelegate <NSObject>

//我委派的任务被点击
- (void)createTaskClicked;
//我负责的任务被点击
- (void)chargeTaskClicked;

@end

@interface TaskView : UIView

@property (nonatomic, weak) id<TaskViewDelegate> delegate;

- (void)setupUI;

@end
