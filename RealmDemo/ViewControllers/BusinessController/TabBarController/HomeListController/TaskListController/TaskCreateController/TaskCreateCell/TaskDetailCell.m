//
//  TaskDetailCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskDetailCell.h"
#import "TaskModel.h"
//名称最长多少字符
#define MAX_STARWORDS_LENGTH 500

@interface TaskDetailCell ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *taskDetail;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@end

@implementation TaskDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.taskDetail.delegate = self;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:self.taskDetail];
    // Initialization code
}
-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textField = (UITextView *)obj.object;
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
                if(self.delegate && [self.delegate respondsToSelector:@selector(taskDetailLenghtOver)]) {
                    [self.delegate taskDetailLenghtOver];
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
            if(self.delegate && [self.delegate respondsToSelector:@selector(taskDetailLenghtOver)]) {
                [self.delegate taskDetailLenghtOver];
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
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    TaskModel *model = self.data;
    model.descriptionStr = textView.text;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView {
    if([NSString isBlank:textView.text])
        self.detailLabel.hidden = NO;
    else
        self.detailLabel.hidden = YES;
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    if([NSString isBlank:model.descriptionStr])
        self.detailLabel.hidden = NO;
    else 
        self.detailLabel.hidden = YES;
    
    self.taskDetail.text = model.descriptionStr;
}

@end
