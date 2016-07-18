//
//  SelectImageViewCell.h
//  fadein
//
//  Created by Apple on 15/12/16.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectImage)();

@interface SelectImageViewCell : UICollectionViewCell

/**
 *  集合视图需要展示的图像
 */
@property (nonatomic, retain) UIImageView *imageView;
/**
 *  选择图像
 */
@property (nonatomic, copy) SelectImage selectImage;

@end
