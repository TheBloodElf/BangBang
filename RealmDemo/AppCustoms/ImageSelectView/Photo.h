//
//  Photo.h
//  图片浏览控件
//
//  Created by Apple on 15/12/8.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
/**
 *  图像对象 优先使用图片对象，如果不存在则使用图片地址
 */
@interface Photo : NSObject

/**
 *  是否被选中
 */
@property (nonatomic, assign) BOOL selected;

//相册对象
@property (nonatomic, retain) ALAsset *alAsset;

/**
 *  当前图片的位置
 */
@property (nonatomic, assign) int index;

/**
 *  原图地址
 */
@property (nonatomic, copy) NSURL *oiginalUrl;

/**
 *  图片的id
 */
@property (nonatomic, retain) NSString *imageId;

/**
 *  原图
 */
@property (nonatomic, retain) UIImage *oiginalImage;

/**
 *  缩略图
 */
@property (nonatomic, retain) UIImage *zoomImage;

/**
 *  缩略图地址
 *
 **/
@property (nonatomic, retain) NSURL *zoomUrl;


/**
 *  从哪个位置进行缩放
 */
@property (nonatomic, assign) CGRect fromRect;

/**
 *  点击时缩放到什么位置
 */
@property (nonatomic, assign) CGRect toRect;

@end
