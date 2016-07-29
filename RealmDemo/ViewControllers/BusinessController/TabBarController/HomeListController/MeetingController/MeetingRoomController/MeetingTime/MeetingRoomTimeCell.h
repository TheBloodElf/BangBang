//
//  MeetingRoomTimeCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomCellModel.h"
//会议时间选择
@protocol MeetingRoomTimeCellDelegate <NSObject>

- (void)MeetingRoomSelectDate:(MeetingRoomCellModel*)model;

@end

@interface MeetingRoomTimeCell : UITableViewCell

@property (nonatomic, weak) id<MeetingRoomTimeCellDelegate> delegate;

@end
