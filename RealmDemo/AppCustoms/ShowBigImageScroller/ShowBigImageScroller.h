//
//  ShowBigImageScroller.h
//  fadein
//
//  Created by Apple on 16/1/15.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Photo.h"
/**
 *  图像被单击的回调     双击是缩小或者放大图像
 */
typedef void(^ClickedBlock)();

/**
 *  显示大图预览的视图
 */
@interface ShowBigImageScroller : UIScrollView

//是否不需要比例，直接放入图像视图
@property (nonatomic, assign) BOOL noNeedScale;
//不需要手势
@property (nonatomic, assign) BOOL noNeedOption;

@property (nonatomic, copy) ClickedBlock clickedBlock;

//操作
@property (nonatomic, assign) int type;

/**
 *  图像对象
 */
@property (nonatomic, retain) Photo *photo;
/**
 *  开始配置界面
 */
- (void)setupUI;
/**
 *  执行动画方法
 */
- (void)loadAnimation;
//初始化成最开始的状态
- (void)reset;

@end
