//
//  MeetingRoomController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomModel.h"
#import "Meeting.h"

//会议室选择
@interface MeetingRoomController : UIViewController

@property (nonatomic, strong) MeetingRoomModel *meetingRoomModel;//已经选择的会议室模型
@property (nonatomic, strong) Meeting *meeting;//会议模型

@end
