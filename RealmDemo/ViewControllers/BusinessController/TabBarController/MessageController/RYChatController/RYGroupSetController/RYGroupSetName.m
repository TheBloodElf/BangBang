//
//  RYGroupSetName.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/25.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RYGroupSetName.h"

@interface RYGroupSetName ()<UITextFieldDelegate> {
    UITextField *_textField;
    UIScrollView *_scrollView;
    RCDiscussion *_currRCDiscussion;//当前讨论组
}

@end

@implementation RYGroupSetName

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改名称";
    self.view.backgroundColor = [UIColor whiteColor];
    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    _scrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT + 0.5);
    [self.view addSubview:_scrollView];
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, MAIN_SCREEN_WIDTH - 40, 30)];
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.placeholder = @"输入讨论组名称";
    _textField.text = _currRCDiscussion.discussionName;
    [_scrollView addSubview:_textField];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_textField.frame) + 10, MAIN_SCREEN_WIDTH - 40, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [_scrollView addSubview:line];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line.frame) + 8, MAIN_SCREEN_HEIGHT - 40, 10)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor grayColor];
    label.text = @"";
    [_scrollView addSubview:label];
    [self.view addSubview:_scrollView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightButtonClicked:)];
    RAC(self.navigationItem.rightBarButtonItem,enabled) = [_textField.rac_textSignal map:^(NSString *value) {
        if([NSString isBlank:value])
            return @(NO);
        return @(YES);
    }];
    // Do any additional setup after loading the view.
}
- (void)dataDidChange {
    _currRCDiscussion = self.data;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)rightButtonClicked:(UIBarButtonItem*)item
{
    [self.view endEditing:YES];
    if(self.delegate && [self.delegate respondsToSelector:@selector(RYGroupSetName:)])
        [self.delegate RYGroupSetName:_textField.text];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
