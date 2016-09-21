//
//  MeetDeviceDetailController.h
//  RealmDemo
//
//  Created by Mac on 16/7/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingEquipmentsModel.h"
#import "Employee.h"
#import "MeetingRoomModel.h"
//查看设备详情
@interface MeetDeviceDetailController : UIViewController

@property (nonatomic, strong) MeetingRoomModel *meetingRoomModel;//会议室模型 用来展示固定设备
@property (nonatomic, strong) NSArray<MeetingEquipmentsModel*> *meetingEquipments;//公共设备数组
@property (nonatomic, strong) Employee *employee;

@end
