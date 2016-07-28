//
//  XYFAnimateLabel.m
//  BangBang
//
//  Created by Xiaoyafei on 15/11/19.
//  Copyright © 2015年 Kiwaro. All rights reserved.
//

#import "XYFAnimateLabel.h"

@implementation XYFAnimateLabel

// Create instance variables/properties for: `from`, `to`, and `startTime` (also include the QuartzCore framework in your project)

- (void)animateFrom:(NSNumber *)aFrom toNumber:(NSNumber *)aTo {
    self.from = aFrom; // or from = [aFrom retain] if your not using @properties
    self.to = aTo;     // ditto
    
    self.text = [_from stringValue];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(animateNumber:)];
    
    _startTime = CACurrentMediaTime();
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)animateNumber:(CADisplayLink *)link {
    float dt = ([link timestamp] - _startTime) / _duration;
    if (dt < 0) {
        dt = 0;
    }
    if (dt >= 1.0) {
        self.text = [_to stringValue];
        [link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        return;
    }
    if (_from == nil) {
        _from = [NSNumber numberWithInt:0];
    }
    float current = ([_to floatValue] - [_from floatValue]) * dt + [_from floatValue];
    self.text = [NSString stringWithFormat:@"%li", (long)current];
}

@end
