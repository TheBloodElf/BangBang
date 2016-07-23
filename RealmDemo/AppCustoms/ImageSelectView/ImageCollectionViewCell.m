//
//  ImageCollectionViewCell.m
//  fadein
//
//  Created by Apple on 15/12/16.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import "Photo.h"

@interface ImageCollectionViewCell  ()
/**
 *  集合视图需要展示的图像
 */
@property (nonatomic, retain) UIImageView *imageView;
@end

@implementation ImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)dataDidChange
{
    Photo *lo_photo = self.data;
    //有缩略图就显示缩略图
    if(lo_photo.oiginalImage)
        _imageView.image = lo_photo.oiginalImage;
    //否者用缩略图url显示
    else
    {
        [_imageView sd_setImageWithURL:lo_photo.oiginalUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            lo_photo.oiginalImage = image;
        }];
    }
}


@end
