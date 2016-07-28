//
//  MeetingRoomModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//会议室信息实体
@interface MeetingRoomModel : NSObject

@property (nonatomic, copy) NSString *room_name;//会议室名称
@property (nonatomic, copy) NSString *in_charge_name;//负责人名称
@property (nonatomic, copy) NSString *in_charge;//负责人GUID
@property (nonatomic, copy) NSString *room_equipments;//会议室固定设备列表,以“,”分割

@end
