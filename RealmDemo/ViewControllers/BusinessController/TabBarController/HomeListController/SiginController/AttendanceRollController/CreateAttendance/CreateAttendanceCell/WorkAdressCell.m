//
//  WorkAdressCell.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/21.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "WorkAdressCell.h"
#import "PunchCardAddressSetting.h"

@interface WorkAdressCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@end

@implementation WorkAdressCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.deleteBtn addTarget:self action:@selector(workAdressCellBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    // Initialization code
}
- (void)workAdressCellBtnAction:(UIButton*)btn
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(workAdressCellBtnAction:)])
        [self.delegate workAdressCellBtnAction:self.data];
}
- (void)dataDidChange {
    PunchCardAddressSetting *setting = self.data;
    self.titleLabel.text = setting.name;
    self.detailLabel.text = setting.address;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
