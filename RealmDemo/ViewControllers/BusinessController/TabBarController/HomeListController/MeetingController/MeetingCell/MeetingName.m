//
//  MeetingName.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingName.h"
#import "Meeting.h"
//名称最长多少字符
#define MAX_STARWORDS_LENGTH 30
@interface MeetingName ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *meetingName;
@end

@implementation MeetingName

- (void)awakeFromNib {
    [super awakeFromNib];
    self.meetingName.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:_meetingName];
    // Initialization code
}
- (void)dataDidChange {
    Meeting *meeting = self.data;
    self.meetingName.text = meeting.title;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    Meeting *meeting = self.data;
    meeting.title = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
-(void)textFiledEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"])// 简体中文输入
    {
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position)
        {
            if (toBeString.length > MAX_STARWORDS_LENGTH)
            {
                if(self.delegate && [self.delegate respondsToSelector:@selector(meetingNameLenghtOver)]) {
                    [self.delegate meetingNameLenghtOver];
                }
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
        }
        
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else
    {
        if (toBeString.length > MAX_STARWORDS_LENGTH)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(meetingNameLenghtOver)]) {
                [self.delegate meetingNameLenghtOver];
            }
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_STARWORDS_LENGTH];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_STARWORDS_LENGTH)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}
@end
