//
//  MeetingDeviceCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomModel.h"
//会议设备
@protocol MeetingDeviceTableCellDelegate <NSObject>
//更多按钮被点击
- (void)MeetingDeviceTableMore;

@end

@interface MeetingDeviceTableCell : UITableViewCell

@property (nonatomic, strong) MeetingRoomModel *meetingRoomModel;//会议室模型 用来展示固定设备
@property (nonatomic, weak) id<MeetingDeviceTableCellDelegate> delegate;

@end
