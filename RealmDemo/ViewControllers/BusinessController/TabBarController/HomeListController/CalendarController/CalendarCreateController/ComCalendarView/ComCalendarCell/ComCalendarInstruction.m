//
//  ComCalendarInstruction.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarInstruction.h"
#import "Calendar.h"

@interface ComCalendarInstruction ()<UITextViewDelegate> {
    Calendar *_calendar;
}

@property (weak, nonatomic) IBOutlet UILabel *detailInstruction;
@property (weak, nonatomic) IBOutlet UITextView *detailInstructionView;

@end

@implementation ComCalendarInstruction

- (void)awakeFromNib {
    [super awakeFromNib];
    self.detailInstructionView.delegate = self;
    // Initialization code
}
- (void)dataDidChange {
    _calendar = self.data;
    self.detailInstructionView.text = _calendar.descriptionStr;
    if([NSString isBlank:_calendar.descriptionStr])
        self.detailInstruction.hidden = NO;
    else
        self.detailInstruction.hidden = YES;
}
#pragma mark --
#pragma mark -- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if([NSString isBlank:_calendar.descriptionStr])
        self.detailInstruction.hidden = NO;
    else
        self.detailInstruction.hidden = YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    _calendar.descriptionStr = textView.text;
    [textView resignFirstResponder];
    return YES;
}
@end
