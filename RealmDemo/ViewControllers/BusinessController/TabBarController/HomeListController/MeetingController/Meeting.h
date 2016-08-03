//
//  Meeting.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//会议模型
@interface Meeting : NSObject

@property (nonatomic, copy) NSString *create_by;//创建者员工GUID
@property (nonatomic, copy) NSString *title;//会议标题
@property (nonatomic, assign) int64_t begin;//开始时间
@property (nonatomic, copy) NSString *ready_man;//准备者员工GUID
@property (nonatomic, assign) int64_t end;//结束时间
@property (nonatomic, copy) NSString *incharge;//主持人
@property (nonatomic, assign) int room_id;//会议室ID
@property (nonatomic, copy) NSString *topic;//议题列表，按显示顺序排列,以“^”分割
@property (nonatomic, copy) NSString *members;//参会人员工GUID列表，以“^”分割
@property (nonatomic, copy) NSString *url;//附件路径列表,已“^”分割
@property (nonatomic, copy) NSString *equipments;//公用设备ID列表,以“^”分割
@property (nonatomic, copy) NSString *attendance;//列席人列表，没有为null，以“^”分割
@property (nonatomic, assign) int before;//提醒时间，可空

@end
