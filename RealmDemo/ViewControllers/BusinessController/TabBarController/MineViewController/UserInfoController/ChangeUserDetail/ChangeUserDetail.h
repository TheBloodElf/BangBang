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

- (void)changeUserInfo:(User*)user;

@end

@interface ChangeUserDetail : UIViewController

@property (nonatomic, weak) id<ChangeUserInfoDelegate> delegate;

@end
