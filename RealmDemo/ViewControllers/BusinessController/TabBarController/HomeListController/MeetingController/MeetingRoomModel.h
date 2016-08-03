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

@property (nonatomic, assign) int room_id;//会议室ID
@property (nonatomic, copy) NSString *room_name;//会议室名称
@property (nonatomic, copy) NSString *in_charge_name;//负责人名称
@property (nonatomic, copy) NSString *in_charge;//负责人GUID
@property (nonatomic, assign) int max;//会议室座位
@property (nonatomic, assign) int64_t begin_time;//会议室开放时间
@property (nonatomic, assign) int64_t end_time;//会议室关闭时间
@property (nonatomic, copy) NSString *room_equipments;//会议室设备列表,以“,”分割

@end
