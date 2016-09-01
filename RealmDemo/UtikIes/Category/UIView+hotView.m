//
//  UIView+hotView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/9/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UIView+hotView.h"
//红点的长宽
#define Hot_View_WidthHeight 7.5

@implementation UIView (hotView)

- (void)addHotView:(HOTVIEW_ALIGNMENT)hotViewAlignment {
    UILabel *hotView = nil;
    for (UILabel *view in self.subviews) {
        if(![view isMemberOfClass:[UILabel class]]) continue;
        if([view.text isEqualToString:@"没错，我就是这么机智的想到这个办法来保证只存在一个红点。"]) {
            hotView = (id)view;
            break;
        }
    }
    if(!hotView) {
        hotView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Hot_View_WidthHeight, Hot_View_WidthHeight)];
        hotView.backgroundColor = [UIColor redColor];
        hotView.text = @"没错，我就是这么机智的想到这个办法来保证只存在一个红点。";
        hotView.textColor = [UIColor clearColor];
        hotView.layer.cornerRadius = Hot_View_WidthHeight / 2.f;
        hotView.clipsToBounds = YES;
        [self addSubview:hotView];
    }
    hotView.center = [self pointWith:hotViewAlignment];
}
- (void)removeHotView {
        for (UILabel *view in self.subviews) {
            if(![view isMemberOfClass:[UILabel class]]) continue;
            if([view.text isEqualToString:@"没错，我就是这么机智的想到这个办法来保证只存在一个红点。"]) {
                [view removeFromSuperview];
                break;
            }
        }
}
- (CGPoint)pointWith:(HOTVIEW_ALIGNMENT)hotViewAlignment {
    CGFloat centerX = self.frame.size.width / 2.f;
    CGFloat centerY = self.frame.size.height / 2.f;
    switch (hotViewAlignment) {
        case HOTVIEW_ALIGNMENT_TOP_LEFT:
            centerX -= self.frame.size.width / 4.f;
            centerY -= self.frame.size.height / 4.f;
            break;
        case HOTVIEW_ALIGNMENT_TOP_RIGHT:
            centerX += self.frame.size.width / 4.f;
            centerY -= self.frame.size.height / 4.f;
            break;
        default:
            break;
    }
    return CGPointMake(centerX, centerY);
}

@end
