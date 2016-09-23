//
//  MeetingRoomModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//选择时间的ITEM模型 里面有开始时间，结束事件
@interface MeetingRoomCellModel : NSObject

@property (nonatomic, strong) NSDate *begin;//开始时间
@property (nonatomic, strong) NSDate *end;//结束时间
@property (nonatomic, assign) BOOL isDidDate;//是否是过去的时间
@property (nonatomic, assign) BOOL isUserSelectDate;//是不是用户选择的时间

@end
