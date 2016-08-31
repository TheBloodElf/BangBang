//
//  MyAppViewCell.h
//  BangBang
//
//  Created by lottak_mac2 on 16/8/29.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserApp.h"

@protocol MyAppViewDelegate <NSObject>

- (void)myAppDeleteApp:(UserApp*)app;

@end

@interface MyAppViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isEditStatue;//是不是编辑状态
@property (nonatomic,   weak) id<MyAppViewDelegate> delegate;

@end
