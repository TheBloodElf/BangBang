//
//  LeftMenuController.h
//  RealmDemo
//
//  Created by Mac on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//侧滑菜单栏
@interface LeftMenuController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *avaterImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMood;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
