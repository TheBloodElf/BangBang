//
//  TaskUpdateController.h
//  RealmDemo
//
//  Created by Mac on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TaskModel;
@protocol TaskUpdateDelegate <NSObject>

- (void)taskUpdate:(TaskModel*)taskModel;

@end
//任务更新
@interface TaskUpdateController : UIViewController

@property (nonatomic, weak) id<TaskUpdateDelegate> delegate;

@end
