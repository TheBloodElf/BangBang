//
//  LineProgressLayer.m
//  Layer
//
//  Created by Carver Li on 14-12-1.
//
//

#import "LineProgressLayer.h"

@implementation LineProgressLayer

-(instancetype)init{
    if (self = [super init]) {
        self.total = 100.0;
        self.radius = 75.0;
        self.innerRadius = 65.0;
        self.startAngle = 0.72 * M_PI;
        self.endAngle = 2.28 * M_PI;
        self.animationDuration = 1.0;
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self)
    {
        if ([layer isKindOfClass:[LineProgressLayer class]])
        {
            LineProgressLayer *other = layer;
            self.total = other.total;
            self.color = other.color;
            self.completed = other.completed;
            self.completedColor = other.completedColor;
            
            self.radius = other.radius;
            self.innerRadius = other.innerRadius;
            
            self.startAngle = other.startAngle;
            self.endAngle = other.endAngle;
            self.shouldRasterize = YES;
        }
    }
    return self;
}

+ (id)layer
{
    LineProgressLayer *result = [[LineProgressLayer alloc] init];
    
    return result;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"completed"])
    {
        return YES;
    }
    
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)contextRef
{
    CGFloat originalRadius = _radius;
    CGFloat totalAngle = _endAngle - _startAngle;
    
    CGRect rect = self.bounds;
    
    CGFloat x0 = (rect.size.width - 2*_radius)/2.0 + _radius;
    CGFloat y0 = (rect.size.height - 2*_radius)/2.0 + _radius;
    
    CGContextSetLineJoin(contextRef, kCGLineJoinBevel);
    CGContextSetFlatness(contextRef, 2.0);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetShouldAntialias(contextRef, true);
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationHigh);

    CGContextSetLineWidth(contextRef,0.8f);     //设置线条宽度
    
    
    for (int i = 0; i < _total; i++) {
        CGContextMoveToPoint(contextRef, x0, y0);
        
        CGFloat x = x0 + cosf(_startAngle + totalAngle*i/_total)*_radius;
        CGFloat y = y0 + sinf(_startAngle + totalAngle*i/_total)*_radius;
        
        CGContextAddLineToPoint(contextRef, x, y);
        CGContextSetStrokeColorWithColor(contextRef, _color.CGColor);   //设置颜色
        CGContextSetFillColorWithColor(contextRef, _color.CGColor);
        CGContextDrawPath(contextRef, kCGPathFillStroke);
        CGContextStrokePath(contextRef);
    }

    for (int i = 0; i < _completed; i++) {
        
        CGContextMoveToPoint(contextRef, x0, y0);
        
        CGFloat x = x0 + cosf(_startAngle + totalAngle*i/_total)*_radius;
        CGFloat y = y0+ sinf(_startAngle + totalAngle*i/_total)*_radius;
        
        CGContextAddLineToPoint(contextRef, x, y);
        CGContextSetStrokeColorWithColor(contextRef, _completedColor.CGColor);  //设置完成颜色
        CGContextSetFillColorWithColor(contextRef, _completedColor.CGColor);
        CGContextStrokePath(contextRef);
        
        if (i + 1 == _completed) {
            _radius = originalRadius;
            break;
        }
    }
    
    //画圆覆盖内部线条
    CGContextAddArc(contextRef, x0, y0, _innerRadius, 0.72*M_PI, 2.28*M_PI, 0);
    CGContextSetFillColorWithColor(contextRef, [UIColor colorWithRed:8 / 255.f green:21 / 255.f blue:64 / 255.f alpha:1].CGColor);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor clearColor].CGColor);     //设置内圆无颜色
    CGContextDrawPath(contextRef, kCGPathFillStroke);
}

-(void)setCompleted:(int)completed
{
    [self setCompleted:completed animated:NO];
}

- (void)setCompleted:(int)completed animated:(BOOL)animated
{
    _completed = completed;
    if (completed == self.completed)
    {
        return;
    }
    
    if (animated && self.animationDuration > 0.0f)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"completed"];
        animation.duration = self.animationDuration;
        animation.fromValue = [NSNumber numberWithFloat:0];
        animation.toValue = [NSNumber numberWithFloat:completed];
        animation.delegate = self;
        [self addAnimation:animation forKey:@"currentAnimation"];
    }
    
    [self setNeedsDisplay];
}

-(void)showAnimate{
    CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"completed"];
    animate.duration = _animationDuration;
    animate.fromValue = [NSNumber numberWithFloat:0];
    animate.toValue = [NSNumber numberWithFloat:_completed];
    [self addAnimation:animate forKey:@"cycleComplete"];
}

@end

