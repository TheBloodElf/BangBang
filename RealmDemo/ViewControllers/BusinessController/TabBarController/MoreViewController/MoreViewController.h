//
//  MoreViewController.h
//  RealmDemo
//
//  Created by Mac on 16/8/6.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//多选视图控制器 创建任务等等
@protocol MoreViewControllerDelegate <NSObject>

- (void)MoreViewDidClicked:(int)index;

@end

@interface MoreViewController : UIViewController

@property (nonatomic, weak) id<MoreViewControllerDelegate> delegate;

@end
