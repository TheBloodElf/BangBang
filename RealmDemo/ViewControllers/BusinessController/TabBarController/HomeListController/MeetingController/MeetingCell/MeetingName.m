//
//  MeetingName.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingName.h"
#import "Meeting.h"

@interface MeetingName ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *meetingName;
@end

@implementation MeetingName

- (void)awakeFromNib {
    [super awakeFromNib];
    self.meetingName.delegate = self;
    // Initialization code
}
- (void)dataDidChange {
    Meeting *meeting = self.data;
    self.meetingName.text = meeting.title;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    Meeting *meeting = self.data;
    NSString *currStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    meeting.title = currStr;
    return YES;
}

@end
