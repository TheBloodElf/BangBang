//
//  MeetingRoomDeviceCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomModel.h"
//会议室列表
@protocol MeetingDeviceDelegate <NSObject>

- (void)MeetingDeviceSelect:(id)device;

@end

@interface MeetingRoomDeviceCell : UITableViewCell

@property (nonatomic, strong) MeetingRoomModel *meetingRoomModel;//会议室模型
@property (nonatomic, weak) id<MeetingDeviceDelegate> delegate;

@end
