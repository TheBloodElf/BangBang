//
//  TaskDiscussSelectPersonController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/9/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserManager.h"
//讨论界面@
@protocol TaskDiscussSelectPersonDelegate <NSObject>

- (void)taskDiscussSelectPerson:(Employee*)employee;
- (void)taskDiscussSelectCancle;

@end

@interface TaskDiscussSelectPersonController : UIViewController

@property (nonatomic, weak) id<TaskDiscussSelectPersonDelegate> delegate;

@end
