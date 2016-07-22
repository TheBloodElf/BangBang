//
//  NoSiginruleView.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/28.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "NoSiginruleView.h"

@interface NoSiginruleView () {
    UIImageView *_imageView;
    UILabel *_titleLabel;
}

@end

@implementation NoSiginruleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_siginrule_icon"]];
        _imageView.frame = CGRectMake(0.5 * (frame.size.width - _imageView.frame.size.width), 100, _imageView.frame.size.width, _imageView.frame.size.height);
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageView.frame) + 20, frame.size.width, 10)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.text = @"没有地点，点击 “+” 新建一个吧";
        [self addSubview:_titleLabel];
    }
    return self;
}
@end
