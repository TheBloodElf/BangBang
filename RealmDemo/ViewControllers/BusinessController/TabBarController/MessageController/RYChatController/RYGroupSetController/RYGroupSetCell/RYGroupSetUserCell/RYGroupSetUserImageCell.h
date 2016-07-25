//
//  RYGroupSetUserImageCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RYGroupSetUserImageDelegate <NSObject>

- (void)RYGroupSetUserImageDelete:(id)userInfo;

@end

@interface RYGroupSetUserImageCell : UICollectionViewCell

@property (nonatomic, assign) BOOL isUserEdit;//是否处于编辑状态
@property (nonatomic, strong) RCDiscussion *currRCDiscussion;
@property (nonatomic, weak) id<RYGroupSetUserImageDelegate> delegate;

@end
