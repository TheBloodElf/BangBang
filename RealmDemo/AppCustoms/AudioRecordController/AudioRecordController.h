//
//  AudioRecordController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//音频录制
@protocol AudioRecordDelegate <NSObject>

- (void)audioRecordFinish:(NSString*)fileurl;

@end

@interface AudioRecordController : UIViewController

@property (nonatomic, weak) id<AudioRecordDelegate> delegate;

@end
