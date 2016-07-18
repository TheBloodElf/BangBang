//
//  UINavigationController+Direction.h
//  fadein
//
//  Created by Maverick on 16/1/12.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NAVIGATION_DIRECTION) {
    E_NAVIGATION_DIRECTION_DOWN,
    E_NAVIGATION_DIRECTION_UP,
    E_NAVIGATION_DIRECTION_RIGHT,
    E_NAVIGATION_DIRECTION_LEFT,
};

@interface UINavigationController (Direction)

- (void)setDirection:(NAVIGATION_DIRECTION)direction;

@end
