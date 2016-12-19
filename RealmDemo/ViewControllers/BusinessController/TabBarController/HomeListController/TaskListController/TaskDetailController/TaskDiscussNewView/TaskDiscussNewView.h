//
//  TaskDiscussNewView.h
//  RealmDemo
//
//  Created by Mac on 2016/11/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"
//任务讨论

@protocol TaskDiscussDelegate <NSObject>

- (void)taskDiscussSelectPersion;

@end

@interface TaskDiscussNewView : UIView

@property (nonatomic, weak) id<TaskDiscussDelegate> delegate;

- (void)setupUI;
- (void)setEmployee:(Employee*)employee;//选择了某个人
- (void)selectCancle;//取消选择

@end
