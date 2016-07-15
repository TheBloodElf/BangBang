//
//  UpdateBushController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/15.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Company.h"
//修改这里要给个回调，然后更新数据，之前的有问题
@protocol UpdateBushDelegate <NSObject>

- (void)updateBush:(Company*)company;

@end

@interface UpdateBushController : UITableViewController

@property (nonatomic, weak) id<UpdateBushDelegate> delegate;

@end
