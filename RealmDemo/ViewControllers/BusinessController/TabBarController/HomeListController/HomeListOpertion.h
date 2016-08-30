//
//  HomeListOpertion.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UserManager.h"
#import "HomeListController.h"
#import "HomeListTopView.h"
#import "HomeListBottomView.h"

@interface HomeListOpertion : NSObject<HomeListTopDelegate,HomeListBottomDelegate,RBQFetchedResultsControllerDelegate>

@property (nonatomic, strong) HomeListController *homeListController;

//开始监听
- (void)startConnect;

@end
