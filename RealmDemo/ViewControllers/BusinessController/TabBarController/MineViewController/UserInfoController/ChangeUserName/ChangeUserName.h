//
//  ChangeUserName.h
//  BangBang
//
//  Created by lottak_mac2 on 16/5/20.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
@protocol ChangeUserNameDelegate <NSObject>

- (void)changeUserInfo:(User*)user;

@end

@interface ChangeUserName : UIViewController

@property (nonatomic, weak) id<ChangeUserNameDelegate> delegate;

@end
