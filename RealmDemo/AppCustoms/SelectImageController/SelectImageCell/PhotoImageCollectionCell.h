//
//  PhotoImageCollectionCell.h
//  fadein
//
//  Created by Apple on 16/1/18.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PhotoDidSelect <NSObject>

- (void)photoDidSelect:(id)photo;

@end


@interface PhotoImageCollectionCell : UICollectionViewCell


@property (nonatomic, weak) id<PhotoDidSelect> delegate;

- (void)setupCameraCell:(UIImage*)image;

@end
