//
//  SelectImageViewCell.m
//  fadein
//
//  Created by Apple on 15/12/16.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import "SelectImageViewCell.h"

@implementation SelectImageViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:_imageView];
        _imageView.image = [UIImage imageNamed:@"picker"];
        
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tgrClicked:)];
        [_imageView addGestureRecognizer:tgr];
    }
    return self;
}
- (void)tgrClicked:(UITapGestureRecognizer*)tgr {
    self.selectImage();
}
@end
