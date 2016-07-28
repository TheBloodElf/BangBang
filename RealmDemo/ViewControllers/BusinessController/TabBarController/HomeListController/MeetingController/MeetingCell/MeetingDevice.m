//
//  MeetingDevice.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingDevice.h"
#import "MeetingEquipmentsModel.h"

@interface MeetingDevice ()
@property (weak, nonatomic) IBOutlet UILabel *meetingDevice;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

@end

@implementation MeetingDevice

- (void)awakeFromNib {
    [super awakeFromNib];
    self.moreBtn.layer.borderColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1].CGColor;
    [self.moreBtn setTitleColor:[UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1] forState:UIControlStateNormal];
    self.moreBtn.layer.borderWidth = 1;
    self.moreBtn.clipsToBounds = YES;
    // Initialization code
}
- (void)dataDidChange {
    NSMutableArray<MeetingEquipmentsModel*> *meetingEquipmentsArr = self.data;
    NSMutableArray<NSString*> *nameArr = [@[] mutableCopy];
    for (MeetingEquipmentsModel *meetingEquipmentsModel in meetingEquipmentsArr) {
        [nameArr addObject:meetingEquipmentsModel.name];
    }
    self.meetingDevice.text = [nameArr componentsJoinedByString:@","];
}
- (IBAction)moreClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingDeviceMore)]) {
        [self.delegate MeetingDeviceMore];
    }
}

@end
