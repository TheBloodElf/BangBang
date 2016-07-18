//
//  ImageSelectView.h
//  fadein
//
//  Created by Apple on 16/1/4.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

//actionsheet show之前  发通知，可以处理隐藏键盘等操作
#define NOTIFICATION_ALERT_SHOW_BENFORE_KEY @"notificaiton_alert_show_before_key"

typedef void(^HeightChange)(CGFloat);

@interface ImageSelectView : UIView

/**
 *  夫视图控制器
 */
@property (nonatomic, weak)UIViewController *presentController;
/**
 *  自身高度改变的回调
 */
@property (nonatomic, copy) HeightChange heightChange;
/**
 *  图像数组
 */
@property (nonatomic, retain) NSMutableArray<Photo*> *photoArr;
/**
 *  最多选择多少张图片
 */
@property (nonatomic, assign) int maxCount;
/**
 *  配置ui界面
 */
- (void)configUI;

//根据图片个数计算整体高度
- (float)calHeightWithImagesCount:(NSInteger)imageCount;

@end
