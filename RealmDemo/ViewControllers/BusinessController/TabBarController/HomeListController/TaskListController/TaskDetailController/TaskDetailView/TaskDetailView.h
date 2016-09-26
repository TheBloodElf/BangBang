//
//  TaskDetailView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//任务详情
@protocol TaskDetailDelegate <NSObject>

//接收
- (void)acceptClicked:(UIButton*)btn task:(id)task;
//终止
- (void)stopClicked:(UIButton*)btn task:(id)task;
//退回
- (void)returnClicked:(UIButton*)btn task:(id)task;
//通过
- (void)passClicked:(UIButton*)btn task:(id)task;
//提交
- (void)submitClicked:(UIButton*)btn task:(id)task;
//查看所有知悉人
- (void)lookMember;

@end

@interface TaskDetailView : UIView

@property (nonatomic, weak) id<TaskDetailDelegate> delegate;

@end
