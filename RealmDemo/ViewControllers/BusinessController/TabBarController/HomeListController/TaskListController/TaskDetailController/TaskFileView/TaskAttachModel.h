//
//  TaskAttachModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttachmentModel.h"
//任务附件实体
@interface TaskAttachModel : NSObject

@property (nonatomic, assign) int id;//任务附件主键
@property (nonatomic, assign) int attachment_id;//附件编号
@property (nonatomic, assign) int task_id;//任务编号
@property (nonatomic, strong) AttachmentModel *attachment;//附件实体

@end
