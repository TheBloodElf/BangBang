//
//  BottomViewItem.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BottomItemModel.h"
//首页下面每个按钮视图
@protocol BottomViewItemDelegate <NSObject>

- (void)bottomItemClicked:(BottomItemModel*)item;

@end

@interface BottomViewItem : UIView

@property (nonatomic, weak) id<BottomViewItemDelegate> delegate;

@end
