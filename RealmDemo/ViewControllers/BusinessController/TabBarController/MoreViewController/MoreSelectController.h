//
//  MoreSelectController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/18.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//多选视图控制器 创建任务等等
@protocol MoreViewControllerDelegate <NSObject>

- (void)MoreViewDidClicked:(int)index;

@end

@interface MoreSelectController : UIViewController

@property (nonatomic, weak) id<MoreViewControllerDelegate> delegate;

@end
