//
//  TaskOtherCommentCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TaskCommentModel;
@protocol TaskOtherCommentDelegate <NSObject>

- (void)TaskOtherAvaterClicked:(TaskCommentModel*)model;

@end

@interface TaskOtherCommentCell : UITableViewCell

@property (nonatomic, weak) id<TaskOtherCommentDelegate> delegate;

@end
