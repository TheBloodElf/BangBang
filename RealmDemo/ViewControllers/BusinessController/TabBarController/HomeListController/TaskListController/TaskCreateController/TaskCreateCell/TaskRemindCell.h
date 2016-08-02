//
//  TaskRemindCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//任务提醒时间
@protocol TaskRemindCellDelegate <NSObject>

- (void)TaskRemindDeleteDate:(NSDate*)date;

@end

@interface TaskRemindCell : UITableViewCell

@property (nonatomic, weak) id<TaskRemindCellDelegate> delegate;

@end
