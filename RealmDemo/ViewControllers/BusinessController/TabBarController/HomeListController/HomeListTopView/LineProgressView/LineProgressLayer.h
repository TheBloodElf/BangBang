//
//  LineProgressLayer.h
//  GLSX
//
//  Created by Carver Li on 14-12-1.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LineProgressLayer : CALayer

@property (nonatomic,assign) int total;
@property (nonatomic,strong) UIColor *color;
@property (nonatomic,assign) int completed;
@property (nonatomic,strong) UIColor *completedColor;

@property (nonatomic,assign) CGFloat radius;
@property (nonatomic,assign) CGFloat innerRadius;

@property CGFloat startAngle;
@property CGFloat endAngle;

@property (nonatomic, assign) CFTimeInterval animationDuration;
-(void)showAnimate;
- (void)setCompleted:(int)completed animated:(BOOL)animated;

@end

