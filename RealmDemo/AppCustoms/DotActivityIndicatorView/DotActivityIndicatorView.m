//
//  DotActivityIndicatorView.m
//  DotsLoaderActivityIndicator
//
//  Created by EhabAlsharkawy on 1/22/16.
//  Copyright © 2016 EhabAlsharkawy. All rights reserved.
//

#import "DotActivityIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

@interface DotActivityIndicatorView ()

@property (nonatomic) NSUInteger numberOfCircles;//有多少个点
@property (nonatomic) CGFloat internalSpacing;//点之间的间隔
@property (nonatomic) CGFloat circleWidth;//每个点的宽度
@property (strong, nonatomic) NSArray *colorArr;//指示器颜色数组 和点一样
@property (nonatomic) CGFloat animationDelay;//第二个点在第一个点启动后多久开始启动
@property (nonatomic) CGFloat animationDuration;//动画时间
//@property (nonatomic) CGFloat animationFromValue;//从点多大开始动画
//@property (nonatomic) CGFloat animationToValue;//动画到点多大

@end

@implementation DotActivityIndicatorView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.numberOfCircles = 3;
        self.internalSpacing = 4.f;
        self.circleWidth = 10;
        self.colorArr = @[[UIColor colorFromHexCode:@"#cccccc"],[UIColor colorFromHexCode:@"#cccccc"],[UIColor colorFromHexCode:@"#cccccc"]];
        self.animationDelay = 0.09;
        self.animationDuration = 0.3;
        //求出动画部分需要多宽 多高  x y点
        CGFloat activityWidth = self.numberOfCircles * self.circleWidth + (self.numberOfCircles - 1) * self.internalSpacing;
        CGFloat activityHeight = self.circleWidth;
        CGFloat activityX = 0.5 * (frame.size.width - activityWidth);
        CGFloat activityY = 0.5 * (frame.size.height - activityHeight);
        //开始创建点
        for (int index = 0; index < self.numberOfCircles; index++) {
            UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(activityX + index * (self.circleWidth + self.internalSpacing), activityY,self.circleWidth,self.circleWidth)];
            circle.layer.cornerRadius = self.circleWidth / 2.f;
            circle.clipsToBounds = YES;
            circle.translatesAutoresizingMaskIntoConstraints = NO;
            circle.backgroundColor = self.colorArr[index];
            //添加动画
            CABasicAnimation *upAnim = [CABasicAnimation animationWithKeyPath:@"position.y"];
            upAnim.fromValue = [NSNumber numberWithFloat:circle.center.y];
            upAnim.toValue = [NSNumber numberWithFloat:circle.center.y + 15];
            upAnim.autoreverses = YES;
            upAnim.duration = self.animationDuration;
            upAnim.removedOnCompletion = NO;
            upAnim.beginTime = CACurrentMediaTime() + index * self.animationDelay;
            upAnim.repeatCount = INFINITY;
            upAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];//开始速度快 后面速度慢
            [circle.layer addAnimation:upAnim forKey:@"upTransform"];
            [self addSubview:circle];
        }
    }
    return self;
}
@end
