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
//查看设备详情
@interface MeetDeviceDetailController : UIViewController

@property (nonatomic, strong) NSArray<MeetingEquipmentsModel*> *meetingEquipments;
@property (nonatomic, strong) Employee *employee;

@end
