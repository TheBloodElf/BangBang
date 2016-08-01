//
//  TaskClickedDelegate.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TaskModel;

@protocol TaskClickedDelegate <NSObject>
//任务被点击了
- (void)taskClicked:(TaskModel*)taskModel;

@end
