//
//  LeftMenuOpertion.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftMenuController.h"
#import "UserManager.h"
#import "LeftMenuCell.h"
//如果代理中涉及到修改界面的 那么修改操作就放到本类中，保证只有一处修改界面的同一部分
//代理中涉及到操作数据的 数据定义应该放到本类  保证数据修改同步
@interface LeftMenuOpertion : NSObject<UITableViewDataSource,UITableViewDelegate,RBQFetchedResultsControllerDelegate>
//开始监听
- (void)startConnect;

@property (nonatomic, strong) LeftMenuController *viewController;

@end
