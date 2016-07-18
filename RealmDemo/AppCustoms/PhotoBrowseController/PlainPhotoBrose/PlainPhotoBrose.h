//
//  PlainPhotoBrose.h
//  fadein
//
//  Created by Apple on 16/1/16.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
@interface PlainPhotoBrose : UIViewController

/**
 *  需要显示的图片数组
 */
@property (nonatomic, retain) NSArray<Photo*> *photoArr;

/**
 *  需要显示的下标
 */
@property (nonatomic, assign) int index;

@end
