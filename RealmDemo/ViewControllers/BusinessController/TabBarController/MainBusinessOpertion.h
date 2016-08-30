//
//  MainBusinessOpertion.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MainBusinessController.h"
#import "MoreSelectController.h"

@interface MainBusinessOpertion : NSObject<UITabBarControllerDelegate,MoreViewControllerDelegate>

@property (nonatomic, strong) MainBusinessController *mainBusinessController;
//开始监听
- (void)startConnect;

@end
