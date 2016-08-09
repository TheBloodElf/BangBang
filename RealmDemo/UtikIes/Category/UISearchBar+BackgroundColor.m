//
//  UISearchBar+UIsearchBarAdd.m
//  SpartaEducation
//
//  Created by kiwi on 14-7-17.
//  Copyright (c) 2014年 NigasMone. All rights reserved.
//

#import "UISearchBar+BackgroundColor.h"

@implementation UISearchBar (BackgroundColor)

- (void)setSearchBarBackgroundColor:(UIColor*)color {
    UIView *subv = [[[self.subviews objectAtIndex: 0] subviews] objectAtIndex:0];
    UIImageView *v = [[UIImageView alloc] initWithFrame:subv.frame];
    v.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin| UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
    v.backgroundColor = color;
    [subv insertSubview:v atIndex:0];
    [self setBackgroundColor:color];
}

@end
