//
//  MeetingRoomHandlerTimeModel.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <Foundation/Foundation.h>
//已经有的会议室占用时间
@interface MeetingRoomHandlerTimeModel : NSObject

@property (nonatomic, assign) int64_t begin;//开始时间
@property (nonatomic, assign) int64_t end;//结束时间
@property (nonatomic, copy  ) NSString *meeting_name;//会议名字

@end
