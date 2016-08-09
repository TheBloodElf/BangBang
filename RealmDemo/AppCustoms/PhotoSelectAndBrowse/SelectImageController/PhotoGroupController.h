//
//  PhotoGroupController.h
//  fadein
//
//  Created by Apple on 16/1/19.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "PhotoGroupTableCell.h"
//选中某个组的回调
@protocol LoadDataWithGroup <NSObject>

- (void)loadDataWithGroup:(ALAssetsGroup*) photoGroup;

@end

@interface PhotoGroupController : UIViewController

@property (nonatomic, weak) id<LoadDataWithGroup> delegate;

@end
