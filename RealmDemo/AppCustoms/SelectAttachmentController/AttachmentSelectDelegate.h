//
//  AttachmentSelectDelegate.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/10.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Attachment;
//附件选择代理 用于显示选择的数量和最后提交数据使用
@protocol AttachmentSelectDelegate <NSObject>

- (void)attachmentDidSelect:(Attachment*)attachment;

@end
