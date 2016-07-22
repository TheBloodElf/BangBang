//
//  PunchCardRemind.h
//  BangBang
//
//  Created by lottak_mac2 on 16/6/21.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import <UIKit/UIKit.h>
//打卡提醒

@protocol PunchCardRemindDelegate <NSObject>

- (void)punchCardRemindSwitchAction:(UISwitch*)sw;

@end

@interface PunchCardRemind : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (nonatomic, weak) id<PunchCardRemindDelegate> delegate;

@end
