//
//  MeetingTimeCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingTimeCell.h"
#import "MeetingRoomCellModel.h"

@interface MeetingTimeCell ()

@property (weak, nonatomic) IBOutlet UILabel *meetingTime;
@property (weak, nonatomic) IBOutlet UIButton *deviceBtn;

@end

@implementation MeetingTimeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    MeetingRoomCellModel *meeting = self.data;
    if(meeting.begin == 0) {
        self.deviceBtn.enabled = NO;
        self.meetingTime.text = @"请在下方选择时间";
        return;
    }
    self.deviceBtn.enabled = YES;
    NSString *timeStr = [NSString stringWithFormat:@"%02ld/%02ld %02ld:%02ld-%02ld:%02ld",meeting.begin.month,meeting.begin.day,meeting.begin.hour,meeting.begin.minute,meeting.end.hour,meeting.end.minute];
    self.meetingTime.text = timeStr;
}
- (IBAction)deviceClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingTimeDevice)]) {
        [self.delegate MeetingTimeDevice];
    }
}


@end
