//
//  TaskDetailBottomOpView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//任务下面的操作按钮
@protocol TaskDetailBottomOpDelegate <NSObject>

//接收
- (void)acceptClicked:(UIButton*)btn;
//终止
- (void)stopClicked:(UIButton*)btn;
//退回
- (void)returnClicked:(UIButton*)btn;
//通过
- (void)passClicked:(UIButton*)btn;
//提交
- (void)submitClicked:(UIButton*)btn;

@end
@interface TaskDetailBottomOpView : UIView

@property (nonatomic, weak) id<TaskDetailBottomOpDelegate> delegate;

@end
