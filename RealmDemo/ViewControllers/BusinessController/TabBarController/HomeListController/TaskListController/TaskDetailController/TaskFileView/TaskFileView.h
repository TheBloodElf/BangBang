//
//  TaskFileView.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//任务附件
@protocol TaskFileDelegate <NSObject>
//上传任务附件
- (void)uploadTaskFile;

@end
@interface TaskFileView : UIView

@property (nonatomic, weak) id<TaskFileDelegate> delegate;

@end
