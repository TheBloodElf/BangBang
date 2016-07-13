//
//  HomeListBottomView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//首页底部的按钮组
@protocol HomeListBottomDelegate <NSObject>
//第几个按钮被点击了
- (void)homeListBottomClicked:(NSInteger)index;

@end

@interface HomeListBottomView : UIView

@property (nonatomic, weak) id<HomeListBottomDelegate> delegate;

@end
