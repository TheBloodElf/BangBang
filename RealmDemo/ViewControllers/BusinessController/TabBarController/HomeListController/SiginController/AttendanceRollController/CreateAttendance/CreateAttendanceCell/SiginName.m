//
//  SiginName.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/24.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SiginName.h"
#import "SiginRuleSet.h"

@interface SiginName  ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputFixed;

@end

@implementation SiginName

- (void)awakeFromNib {
    [super awakeFromNib];
    self.inputFixed.delegate = self;
    self.inputFixed.returnKeyType = UIReturnKeyDone;
    // Initialization code
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    SiginRuleSet *currSiginRule = self.data;
    currSiginRule.setting_name = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)dataDidChange {
    SiginRuleSet *currSiginRule = self.data;
    self.inputFixed.text = currSiginRule.setting_name;
}

@end
