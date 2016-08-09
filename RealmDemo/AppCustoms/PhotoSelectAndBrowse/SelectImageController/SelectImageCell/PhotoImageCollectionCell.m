//
//  PhotoImageCollectionCell.m
//  fadein
//
//  Created by Apple on 16/1/18.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "PhotoImageCollectionCell.h"
#import "Photo.h"
@interface PhotoImageCollectionCell ()

@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation PhotoImageCollectionCell

- (void)dataDidChange
{
    Photo *lo_photo = self.data;
    
    self.selectBtn.hidden = NO;
    
    if(lo_photo.selected == YES)
        self.selectBtn.selected = YES;
    else
        self.selectBtn.selected = NO;
    
    [self.selectBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.photoImageView.image = [UIImage imageWithCGImage:[lo_photo.alAsset aspectRatioThumbnail]];
}

- (void)btnClicked:(UIButton*)btn {
    if(self.delegate)
        [self.delegate photoDidSelect:self.data];
}

- (void)setupCameraCell:(UIImage*)image{
    self.photoImageView.image = image;
    self.selectBtn.hidden = YES;
    
}

@end
