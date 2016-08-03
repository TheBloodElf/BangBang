//
//  TaskFileImageCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TaskFileImageDelegate <NSObject>

- (void)TaskFileImageDelete:(id)file;

@end

@interface TaskFileImageCell : UITableViewCell

@property (nonatomic, weak) id<TaskFileImageDelegate> delegate;

@end
