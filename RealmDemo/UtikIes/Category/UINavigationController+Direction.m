//
//  UINavigationController+Direction.m
//  fadein
//
//  Created by Maverick on 16/1/12.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "UINavigationController+Direction.h"

@implementation UINavigationController (Direction)

- (void)setDirection:(NAVIGATION_DIRECTION)direction {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    if (direction == E_NAVIGATION_DIRECTION_UP) {
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
    }
    else if(direction == E_NAVIGATION_DIRECTION_DOWN){
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
    }
    else if (direction == E_NAVIGATION_DIRECTION_RIGHT)
    {
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromRight;
    }
    else
    {
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromLeft;
    }
    transition.delegate = self;
    [self.view.layer addAnimation:transition forKey:nil];
}

@end
