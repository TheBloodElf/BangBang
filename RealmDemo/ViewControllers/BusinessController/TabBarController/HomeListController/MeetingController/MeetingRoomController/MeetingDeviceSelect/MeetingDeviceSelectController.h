//
//  MeetingDeviceSelectController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingEquipmentsModel.h"
#import "MeetingRoomModel.h"
#import "MeetingRoomCellModel.h"
#import "UserManager.h"
//会议设备选择
@protocol MeetingDeviceSelectDelegate <NSObject>
//公共设备选择完毕 返回准备人和设备数组
- (void)MeetingDeviceSelect:(NSArray<MeetingEquipmentsModel*>*)array employee:(Employee*)employee;

@end

@interface MeetingDeviceSelectController : UIViewController

@property (nonatomic, strong) MeetingRoomModel *meetingRoomModel;//会议室模型 用来展示固定设备
@property (nonatomic, strong) MeetingRoomCellModel *userSelectDate;//用选择的时间
@property (nonatomic, weak) id<MeetingDeviceSelectDelegate> delegate;

@end
