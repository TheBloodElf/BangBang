//
//  LineProgressView.m
//  Layer
//
//  Created by Carver Li on 14-12-1.
//
//

#import "LineProgressView.h"

@implementation LineProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (void)_defaultInit
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    self.total = 100;
    self.color = [UIColor blackColor];
    self.completed = 0;
    self.completedColor = [UIColor colorWithRed:10.0/255.0 green:185.0/255.0 blue:150.0/255.0 alpha:1.0];
    
    self.radius = 30.0;
    self.innerRadius = 20.0;
    
    self.startAngle = 0;
    self.endAngle = M_PI*2;
}

+ (Class)layerClass
{
    return [LineProgressLayer class];
}

- (void)setTotal:(int)total
{
    _total = total;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.total = total;
    [layer setNeedsDisplay];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.color = color;
    [layer setNeedsDisplay];
}

- (void)setCompletedColor:(UIColor *)completedColor
{
    _completedColor = completedColor;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.completedColor = completedColor;
    [layer setNeedsDisplay];
}

-(void)setCompleted:(int)completed
{
    [self setCompleted:completed animated:NO];
}

- (void)setCompleted:(int)completed animated:(BOOL)animated
{
    if (completed == self.completed)
    {
        return;
    }
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    if (animated && self.animationDuration > 0.0f)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"completed"];
        animation.duration = self.animationDuration;
        animation.fromValue = [NSNumber numberWithFloat:self.completed];
        animation.toValue = [NSNumber numberWithFloat:completed];
        animation.delegate = self;
        [self.layer addAnimation:animation forKey:@"currentAnimation"];
    }
    
    [layer setNeedsDisplay];
}


- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.radius = radius;
    [layer setNeedsDisplay];
}

- (void)setInnerRadius:(CGFloat)innerRadius
{
    _innerRadius = innerRadius;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.innerRadius = innerRadius;
    [layer setNeedsDisplay];
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _startAngle = startAngle;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.startAngle = startAngle;
    [layer setNeedsDisplay];
}

- (void)setEndAngle:(CGFloat)endAngle
{
    _endAngle = endAngle;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.endAngle = endAngle;
    [layer setNeedsDisplay];
}

- (void)setAnimationDuration:(CFTimeInterval)animationDuration
{
    _animationDuration = animationDuration;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.animationDuration = animationDuration;
    [layer setNeedsDisplay];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(LineProgressViewAnimationDidStart:)]) {
        [self.delegate LineProgressViewAnimationDidStart:self];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(LineProgressViewAnimationDidStop:)]) {
        [self.delegate LineProgressViewAnimationDidStop:self];
    }
}

@end

