//
//  PushMessageOpertion.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "PushMessageController.h"
#import "UserManager.h"

@interface PushMessageOpertion : NSObject<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,RBQFetchedResultsControllerDelegate>

@property (nonatomic, strong) PushMessageController *pushMessageController;
//开始监听
- (void)startConnect;

@end
