//
//  ChangeUserName.h
//  BangBang
//
//  Created by lottak_mac2 on 16/5/20.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@protocol ChangeUserInfoDelegate <NSObject>

- (void)changeUserBBH:(User*)user;

@end

@interface ChangeUserBBH : UIViewController

@property (nonatomic, weak) id<ChangeUserInfoDelegate> delegate;

@end
