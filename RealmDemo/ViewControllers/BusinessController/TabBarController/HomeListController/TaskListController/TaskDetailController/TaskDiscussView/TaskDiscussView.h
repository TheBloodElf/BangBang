//
//  TaskDiscussView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"
//任务讨论

@protocol TaskDiscussDelegate <NSObject>

- (void)taskDiscussSelectPersion;

@end

@interface TaskDiscussView : UIView

@property (nonatomic, weak) id<TaskDiscussDelegate> delegate;

- (void)setEmployee:(Employee*)employee;
- (void)selectCancle;

@end
