//
//  AppCenterView.h
//  BangBang
//
//  Created by lottak_mac2 on 16/8/29.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserApp;

@protocol AppCenterDelegate <NSObject>

- (void)appCenterAddApp:(UserApp*)app;
- (void)appCenterDelApp:(UserApp*)app;

@end

@interface AppCenterView : UIView

@property (nonatomic, assign) BOOL isEditStatue;//是不是编辑状态
@property (nonatomic, weak) id<AppCenterDelegate> delegate;

- (void)reloadCollentionView;//重新加载界面

@end
