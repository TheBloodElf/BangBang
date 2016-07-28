//
//  MeetingAgendaCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/28.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingAgendaCell.h"
#import "MeetingAgenda.h"

@interface MeetingAgendaCell ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *agendaNumber;
@property (weak, nonatomic) IBOutlet UITextField *agendaText;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation MeetingAgendaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.agendaText.delegate = self;
    // Initialization code
}
- (void)dataDidChange {
    MeetingAgenda *meetingAgenda = self.data;
    self.agendaText.text = meetingAgenda.title;
    self.agendaNumber.text = [NSString stringWithFormat:@"%d",meetingAgenda.index];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
     MeetingAgenda *meetingAgenda = self.data;
    meetingAgenda.title = textField.text;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    MeetingAgenda *meetingAgenda = self.data;
    NSString *currStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    meetingAgenda.title = currStr;
    return YES;
}
- (IBAction)deleteClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingAgendaDelete:)]) {
        [self.delegate MeetingAgendaDelete:self.data];
    }
}

@end
