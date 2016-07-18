//
//  AllowSelectPhotoBrose.h
//  fadein
//
//  Created by Apple on 16/1/16.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@protocol AllowSelectDelegate <NSObject>

@optional

- (void) allowSelectReturn;

- (void) allowSelectFinish:(NSMutableArray<Photo*> *) allSelecArr;

@end

@interface AllowSelectPhotoBrose : UIViewController

/**
 *  需要显示的图片数组
 */
@property (nonatomic, retain) NSMutableArray<Photo*> *photoArr;

@property (nonatomic, weak) id<AllowSelectDelegate> delegate;

@end
