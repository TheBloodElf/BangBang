//
//  CreateMeetingController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
//创建会议
typedef void(^CreateFinish)();
@interface CreateMeetingController : UIViewController

@property (nonatomic, copy) CreateFinish createFinish;

@end
