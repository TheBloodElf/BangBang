//
//  RYChatController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/18.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UserManager.h"
//聊天界面 单聊targetId为对方的user_no 群聊时targetId为圈子编号  讨论组时把圈子编号传进来
@interface RYChatController : RCConversationViewController

@property (nonatomic, assign) int companyNo;

@end
