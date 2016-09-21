//
//  MeetingDeviceCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingDeviceCell.h"
#import "MeetingRoomModel.h"

@interface MeetingDeviceCell ()
@property (weak, nonatomic) IBOutlet UILabel *roomName;
@property (weak, nonatomic) IBOutlet UILabel *roomTime;
@property (weak, nonatomic) IBOutlet UILabel *roomNumber;

@end

@implementation MeetingDeviceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
    self.clipsToBounds = YES;
    self.roomName.adjustsFontSizeToFitWidth = YES;
    // Initialization code
}
- (void)dataDidChange {
    MeetingRoomModel *model = self.data;
    if(model.room_id == self.meetingRoomModel.room_id) {//是不是当前已经选择的会议室
        self.roomName.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    } else {
        self.roomName.backgroundColor = [UIColor lightGrayColor];
    }
    self.roomName.text = model.room_name;
    NSDate *begin = [NSDate dateWithTimeIntervalSince1970:model.begin_time / 1000];
    NSDate *end = [NSDate dateWithTimeIntervalSince1970:model.end_time / 1000];
    self.roomTime.text = [NSString stringWithFormat:@"%02ld:%02ld~%02ld:%02ld",begin.hour,begin.minute,end.hour,end.minute];
    self.roomNumber.text = [NSString stringWithFormat:@"容纳%d人",model.max];
}
@end
