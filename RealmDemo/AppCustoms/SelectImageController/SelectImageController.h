//
//  SelectImageController.h
//  fadein
//
//  Created by Apple on 16/1/18.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "AllowSelectPhotoBrose.h"
#import "BigPhotoSelectController.h"
//照片选取完的回调
@protocol SelectImageDelegate <NSObject>

@optional

- (void)selectImageReturn;

- (void)selectImageFinish:(NSMutableArray<Photo*>*)photoArr;

- (void)selectCameraReturn;

@end

@interface SelectImageController : UIViewController

@property (nonatomic, assign)BOOL showCameraCell;

/**
 *  最大选择数
 */
@property (nonatomic, assign) int maxSelect;

@property (nonatomic, retain) id<SelectImageDelegate> delegate;

@end
