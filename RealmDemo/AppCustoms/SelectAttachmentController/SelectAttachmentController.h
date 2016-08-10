//
//  SelectAttachmentController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//选择附件控制器 (里面有图片一栏)
@class Attachment;
@protocol SelectAttachmentDelegate <NSObject>
//选择成功
- (void)selectAttachmentFinish:(NSMutableArray<Attachment*>*)attachmentArr;
//选择成功
- (void)selectAttachmentCancel;
@end

@interface SelectAttachmentController : UIViewController

@property (nonatomic, weak) id<SelectAttachmentDelegate> delegate;

@property (nonatomic, assign) int maxSelect;//最大选择数量

@end
