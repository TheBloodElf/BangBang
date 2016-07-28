//
//  MeetingEquipmentsModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//会议设备实体
@interface MeetingEquipmentsModel : NSObject

@property (nonatomic, assign) int id;//设备ID
@property (nonatomic, copy) NSString *name;//设备名称
@property (nonatomic, assign) int type;//设备类型；0-会议室固定设备；1-公用设备

@end
