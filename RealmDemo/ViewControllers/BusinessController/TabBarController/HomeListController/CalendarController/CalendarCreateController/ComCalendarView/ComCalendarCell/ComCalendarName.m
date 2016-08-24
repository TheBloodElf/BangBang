//
//  ComCalendarName.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarName.h"
#import "Calendar.h"

@interface ComCalendarName ()<UITextFieldDelegate> {
    Calendar *_calendar;
}
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;

@end

@implementation ComCalendarName

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.delegate = self;
    // Initialization code
}
- (void)dataDidChange {
    _calendar = self.data;
    self.nameLabel.text = _calendar.event_name;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    _calendar.event_name = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
