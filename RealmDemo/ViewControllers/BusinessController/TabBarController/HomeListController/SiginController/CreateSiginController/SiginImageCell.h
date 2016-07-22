//
//  SiginImageCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/22.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SiginImageDelegate <NSObject>

- (void)SiginImageDelete:(UIImage*)image;

@end

@interface SiginImageCell : UICollectionViewCell

@property (nonatomic, weak) id<SiginImageDelegate> delegate;

@end
