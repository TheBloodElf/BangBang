//
//  TabBarController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//主业务控制器
//用来加载进入程序就要刷新的数据 与 有网络就要重新获取的数据
//通知、today等扩展处理跳转在这个控制器 所以内容比较多
@interface MainBusinessController : UIViewController

- (instancetype)initWithOptions:(NSDictionary *)launchOptions;

@end
