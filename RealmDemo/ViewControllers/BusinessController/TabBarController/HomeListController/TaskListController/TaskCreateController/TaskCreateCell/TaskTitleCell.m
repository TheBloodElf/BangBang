//
//  TaskTitleCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/1.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "TaskTitleCell.h"
#import "TaskModel.h"

@interface TaskTitleCell ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *taskTitle;

@end

@implementation TaskTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.taskTitle.delegate = self;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    TaskModel *model = self.data;
    model.task_name = textField.text;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    TaskModel *model = self.data;
    model.task_name = textField.text;
    [self.contentView endEditing:YES];
    return YES;
}
- (void)dataDidChange {
    TaskModel *model = self.data;
    self.taskTitle.text = model.task_name;
}

@end
