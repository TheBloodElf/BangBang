//
//  XYFAnimateLabel.h
//  BangBang
//
//  Xiaoyafei on 15/11/19.
//  Copyright © 2015年 Kiwaro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYFAnimateLabel : UILabel
@property(nonatomic,strong)NSNumber *from;
@property(nonatomic,strong)NSNumber *to;
@property(nonatomic,assign)CFTimeInterval startTime;
@property(nonatomic,assign)float duration;
- (void)animateFrom:(NSNumber *)aFrom toNumber:(NSNumber *)aTo;
@end
