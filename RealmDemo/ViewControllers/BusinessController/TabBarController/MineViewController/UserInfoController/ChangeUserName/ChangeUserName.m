//
//  ChangeUserName.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/20.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "ChangeUserName.h"
#import "UserManager.h"

@interface ChangeUserName ()<UITextFieldDelegate,UIScrollViewDelegate>
{
    UITextField *_textField;
    UIScrollView *_scrollView;
    User *_currUser;
}
@end

@implementation ChangeUserName

- (void)viewDidLoad {
    [super viewDidLoad];
    _currUser = [User copyFromUser:[UserManager manager].user];
    self.title = @"修改名字";
    self.view.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    _scrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT + 0.5);
    [self.view addSubview:_scrollView];
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, MAIN_SCREEN_WIDTH - 40, 30)];
    _textField.delegate = self;
    _textField.placeholder = @"名字不能超过5个字!";
    _textField.text = _currUser.real_name;
    [_scrollView addSubview:_textField];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_textField.frame) + 10, MAIN_SCREEN_WIDTH - 40, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [_scrollView addSubview:line];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line.frame) + 8, MAIN_SCREEN_WIDTH - 40, 10)];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor grayColor];
    label.text = @"请输入你想要的名字";
    [_scrollView addSubview:label];
    [self.view addSubview:_scrollView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightButtonClicked:)];
    // Do any additional setup after loading the view from its nib.
}
- (void)rightButtonClicked:(UIBarButtonItem*)item
{
    [self.view endEditing:YES];
    if([NSString isBlank:_textField.text])
    {
        [self.navigationController.view showMessageTips:@"请输入内容"];
        return;
    }
    [self.delegate changeUserInfo:_currUser];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _currUser.real_name = textField.text;
}
@end
