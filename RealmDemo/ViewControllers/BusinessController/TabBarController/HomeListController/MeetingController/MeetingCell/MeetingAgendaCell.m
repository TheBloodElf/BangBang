//
//  MeetingAgendaCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingAgendaCell.h"
#import "MeetingAgenda.h"
//名称最长多少字符
#define MAX_STARWORDS_LENGTH 30

@interface MeetingAgendaCell ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *agendaNumber;
@property (weak, nonatomic) IBOutlet UITextField *agendaText;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation MeetingAgendaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.agendaText.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:_agendaText];
    // Initialization code
}
- (void)dataDidChange {
    MeetingAgenda *meetingAgenda = self.data;
    self.agendaText.text = meetingAgenda.title;
    self.agendaNumber.text = [NSString stringWithFormat:@"%d",meetingAgenda.index + 1];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    MeetingAgenda *meetingAgenda = self.data;
    meetingAgenda.title = textField.text;
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingAgendaFinishEdit)]) {
        [self.delegate MeetingAgendaFinishEdit];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)deleteClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingAgendaDelete:)]) {
        [self.delegate MeetingAgendaDelete:self.data];
    }
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
                if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingAgendaLenghtOver)]) {
                    [self.delegate MeetingAgendaLenghtOver];
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
            if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingAgendaLenghtOver)]) {
                [self.delegate MeetingAgendaLenghtOver];
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
