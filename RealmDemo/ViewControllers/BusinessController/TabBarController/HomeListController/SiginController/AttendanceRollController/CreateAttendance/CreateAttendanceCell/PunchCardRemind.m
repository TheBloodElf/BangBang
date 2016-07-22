//
//  PunchCardRemind.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/21.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "PunchCardRemind.h"

@interface PunchCardRemind ()

@end

@implementation PunchCardRemind

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.onOffSwitch addTarget:self action:@selector(punchCardRemindSwitchAction:) forControlEvents:UIControlEventValueChanged];
    // Initialization code
}
- (void)punchCardRemindSwitchAction:(UISwitch*)sw {
    if(self.delegate && [self.delegate respondsToSelector:@selector(punchCardRemindSwitchAction:)])
        [self.delegate punchCardRemindSwitchAction:sw];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
