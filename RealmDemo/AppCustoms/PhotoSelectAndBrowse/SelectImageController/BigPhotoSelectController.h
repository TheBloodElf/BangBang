//
//  BigPhotoSelectController.h
//  fadein
//
//  Created by Apple on 16/1/19.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@protocol BigPhotoSelectDelegate <NSObject>

@optional

- (void)bigPhotoSelectReturn;

- (void)bigPhotoSelectFinish:(NSMutableArray<Photo*>*)photoArr;

@end

@interface BigPhotoSelectController : UIViewController

/**
 *  需要显示的图片数组
 */
@property (nonatomic, retain) NSMutableArray<Photo*> *photoArr;

//选图的回调
@property (nonatomic, retain) id<BigPhotoSelectDelegate> delegate;


//需要显示的下标
@property (nonatomic, assign) int index;

//最大的选折数
@property (nonatomic, assign) int maxCount;

@end
