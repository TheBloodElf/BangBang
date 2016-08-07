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
    Calendar *calendar = self.data;
    self.detailInstructionView.text = calendar.descriptionStr;
    if([NSString isBlank:calendar.descriptionStr])
        self.detailInstruction.hidden = NO;
    else
        self.detailInstruction.hidden = YES;
}
#pragma mark --
#pragma mark -- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    if([NSString isBlank:textView.text])
        self.detailInstruction.hidden = NO;
    else
        self.detailInstruction.hidden = YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    Calendar *calendar = self.data;
    calendar.descriptionStr = textView.text;
    return YES;
}
@end
