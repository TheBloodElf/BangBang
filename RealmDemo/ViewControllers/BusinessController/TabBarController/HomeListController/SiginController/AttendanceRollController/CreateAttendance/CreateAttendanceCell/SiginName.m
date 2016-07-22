//
//  SiginName.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/24.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SiginName.h"

@interface SiginName  ()<UITextFieldDelegate>

@end

@implementation SiginName

- (void)awakeFromNib {
    [super awakeFromNib];
    self.inputFixed.delegate = self;
    // Initialization code
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(siginNameTextField:)]) {
        [self.delegate siginNameTextField:textField];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
