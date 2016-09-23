//
//  RYGroupSetController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RYGroupSetDelegate <NSObject>
//讨论组名字修改了
- (void)rYGroupSetNameChange:(NSString*)name;
//讨论组清除聊天记录
- (void)rYGroupClearChatNote;

@end

@interface RYGroupSetController : UIViewController

@property (nonatomic, copy) NSString *targetId;//会话ID，用来获取成员
@property (nonatomic, weak) id<RYGroupSetDelegate> delegate;

@end
