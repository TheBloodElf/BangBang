//
//  MeetingDeviceSelectCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingDeviceSelectCell.h"
#import "MeetingEquipmentsModel.h"

@interface MeetingDeviceSelectCell ()

@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation MeetingDeviceSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dataDidChange {
    MeetingEquipmentsModel *model = self.data;
    self.nameLabel.text = model.name;
    self.selectBtn.selected = model.isSelect;
}

@end
