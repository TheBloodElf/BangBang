//
//  VideoRecordController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//视频录制控制器

@protocol VideoRecordDelegate <NSObject>

- (void)videoRecordFinish:(NSString*)fileUrl;

@end

@interface VideoRecordController : UIViewController

@property (nonatomic, weak) id<VideoRecordDelegate> delegate;

@end
