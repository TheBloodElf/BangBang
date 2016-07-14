//
//  MoreSelectView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/14.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//弹出一个选择视图 然后回调
@protocol MoreSelectViewDelegate <NSObject>

- (void)moreSelectIndex:(int)index;

@end

@interface MoreSelectView : UIView

@property (nonatomic, assign) BOOL isHide;//是不是隐藏的
@property (nonatomic, strong) NSArray *selectArr;
@property (nonatomic, weak  ) id<MoreSelectViewDelegate> delegate;

- (void)setupUI;
- (void)showSelectView;//显示选择视图
- (void)hideSelectView;//隐藏选择视图

@end
