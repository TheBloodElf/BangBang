//
//  NoResultView.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/24.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "NoResultView.h"

@implementation NoResultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *iamgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_result_icon"]];
        iamgeView.frame = CGRectMake(0.5 * (frame.size.width - iamgeView.frame.size.width), 0.5 * (frame.size.height - iamgeView.frame.size.height), iamgeView.frame.size.width, iamgeView.frame.size.height);
        [self addSubview:iamgeView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(-11, 0.5 * (iamgeView.frame.size.height - 10) + 18, iamgeView.frame.size.width, 10)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:14];
        label.text = @"没有更多数据";
        [iamgeView addSubview:label];
    }
    return self;
}

@end
