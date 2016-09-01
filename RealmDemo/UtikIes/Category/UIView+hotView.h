//
//  UIView+hotView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/9/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, HOTVIEW_ALIGNMENT) {
    HOTVIEW_ALIGNMENT_TOP_LEFT,
    HOTVIEW_ALIGNMENT_TOP_RIGHT
};
@interface UIView (hotView)

- (void)addHotView:(HOTVIEW_ALIGNMENT)hotViewAlignment;
- (void)removeHotView;

@end
