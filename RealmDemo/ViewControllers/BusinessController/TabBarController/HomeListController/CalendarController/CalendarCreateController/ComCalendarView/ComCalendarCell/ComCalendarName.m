//
//  ComCalendarName.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarName.h"
#import "Calendar.h"

#define MAX_STARWORDS_LENGTH 30

@interface ComCalendarName ()<UITextFieldDelegate> {
    Calendar *_calendar;
}
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;

@end

@implementation ComCalendarName

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:self.nameLabel];
    // Initialization code
}
- (void)dataDidChange {
    _calendar = self.data;
    self.nameLabel.text = _calendar.event_name;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    _calendar.event_name = textField.text;
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
                if(self.delegate && [self.delegate respondsToSelector:@selector(comCalendarNameLengthOver)]) {
                    [self.delegate comCalendarNameLengthOver];
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
            if(self.delegate && [self.delegate respondsToSelector:@selector(comCalendarNameLengthOver)]) {
                [self.delegate comCalendarNameLengthOver];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
@end
