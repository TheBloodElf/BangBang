//
//  ImageScrollView.h
//  fadein
//
//  Created by Apple on 16/1/6.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

typedef void(^ScrollToIndex)(int);

@interface ImageScrollView : UIView


@property (nonatomic, copy) ScrollToIndex scrollToIndex;


@end
