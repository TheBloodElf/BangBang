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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:_detailInstructionView];
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
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    Calendar *calendar = self.data;
    calendar.descriptionStr = textView.text;
    return YES;
}
-(void)textViewEditChanged:(NSNotification *)obj
{
    if([NSString isBlank:_detailInstructionView.text])
        self.detailInstruction.hidden = NO;
    else
        self.detailInstruction.hidden = YES;
    UITextView *textField = (UITextView *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]){// 简体中文输入
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 500) {
                if(self.delegate && [self.delegate respondsToSelector:@selector(comCalendarInstructionOverLength)]) {
                    [self.delegate comCalendarInstructionOverLength];
                }
                textField.text = [toBeString substringToIndex:500];
            }
        }
    } else {// 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > 500) {
            if(self.delegate && [self.delegate respondsToSelector:@selector(comCalendarInstructionOverLength)]) {
                [self.delegate comCalendarInstructionOverLength];
            }
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:500];
            if (rangeIndex.length == 1) {
                textField.text = [toBeString substringToIndex:500];
            } else {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 500)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

@end
