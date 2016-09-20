//
//  TaskDetailCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//任务详情

@protocol TaskDetailCellDelegate <NSObject>

- (void)taskDetailLenghtOver;

@end

@interface TaskDetailCell : UITableViewCell

@property (nonatomic, weak) id<TaskDetailCellDelegate> delegate;

@end
