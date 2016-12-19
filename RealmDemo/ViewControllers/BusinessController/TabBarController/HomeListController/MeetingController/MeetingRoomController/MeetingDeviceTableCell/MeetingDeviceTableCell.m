//
//  MeetingDeviceCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingDeviceTableCell.h"
#import "MeetingEquipmentsModel.h"

@interface MeetingDeviceTableCell ()
@property (weak, nonatomic) IBOutlet UILabel *meetingDevice;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@end

@implementation MeetingDeviceTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    NSArray<MeetingEquipmentsModel*> *array = self.data;
    if(array.count == 0) {
        self.meetingDevice.text = @"无设备";
        self.moreBtn.enabled = NO;
        return;
    }
    self.moreBtn.enabled = YES;
    NSMutableArray<NSString*> *nameArr = [@[] mutableCopy];
    //获取固定设备
    for (NSString *str in [self.meetingRoomModel.room_equipments componentsSeparatedByString:@","]) {
        if([NSString isBlank:str]) continue;
        [nameArr addObject:str];
    }
    //获取公共设备
    for (MeetingEquipmentsModel *model in array) {
        [nameArr addObject:model.name];
    }
    self.meetingDevice.text = [nameArr componentsJoinedByString:@","];
}
- (IBAction)moreClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingDeviceTableMore)]) {
        [self.delegate MeetingDeviceTableMore];
    }
}


@end
