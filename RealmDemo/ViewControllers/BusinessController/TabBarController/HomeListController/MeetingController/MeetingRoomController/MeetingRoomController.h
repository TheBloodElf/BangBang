//
//  MeetingRoomController.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomModel.h"
#import "Meeting.h"
#import "MeetingEquipmentsModel.h"
#import "MeetingRoomCellModel.h"
#import "UserManager.h"

//会议室选择
@protocol MeetingRoomDelegate <NSObject>

- (void)MeetingRoomDeviceSelect:(NSArray<MeetingEquipmentsModel*>*)array meetingRoom:(MeetingRoomModel*)meetingRoom employee:(Employee*)employee meetingRoomTime:(MeetingRoomCellModel*)meetingRoomTime;

@end

@interface MeetingRoomController : UIViewController

@property (nonatomic, weak) id<MeetingRoomDelegate> delegate;

@end
