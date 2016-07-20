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
    self.adressLabel.delegate = self;
    // Initialization code
}

- (void)dataDidChange {
    _calendar = self.data;
    self.adressLabel.text = _calendar.address;
}
#pragma mark --
#pragma mark -- UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    _calendar.address = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return YES;
}
@end
