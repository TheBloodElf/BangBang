//
//  ComCalendarAdress.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarAdress.h"
#import "Calendar.h"

@interface ComCalendarAdress ()<UITextFieldDelegate> {
    Calendar *_calendar;
}
@property (weak, nonatomic) IBOutlet UITextField *adressLabel;

@end

@implementation ComCalendarAdress

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dataDidChange {
    _calendar = self.data;
    self.adressLabel.text = _calendar.address;
}
#pragma mark --
#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    _calendar.address = textField.text;
    return YES;
}
@end
