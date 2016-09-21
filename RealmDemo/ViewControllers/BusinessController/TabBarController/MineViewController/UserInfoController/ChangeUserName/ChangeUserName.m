//
//  ChangeUserName.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/20.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "ChangeUserName.h"
#import "UserManager.h"
//名称最长多少字符
#define MAX_STARWORDS_LENGTH 5

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
    _currUser = [[UserManager manager].user deepCopy];
    self.title = @"修改名字";
    self.view.backgroundColor = [UIColor whiteColor];
    _scrollView.delegate = self;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64)];
    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _scrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT + 0.5);
    [self.view addSubview:_scrollView];
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, MAIN_SCREEN_WIDTH - 40, 30)];
    _textField.delegate = self;
    _textField.placeholder = @"名字不能超过5个字!";
    _textField.text = _currUser.real_name;
    _textField.returnKeyType = UIReturnKeyDone;
    [_scrollView addSubview:_textField];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:) name:@"UITextFieldTextDidChangeNotification" object:_textField];
    
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
    //按钮是否能够被点击
    RAC(self.navigationItem.rightBarButtonItem,enabled) = [_textField.rac_textSignal map:^(NSString *user_name) {
        if([NSString isBlank:user_name])
            return @(NO);
        return @(YES);
    }];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)rightButtonClicked:(UIBarButtonItem*)item
{
    [self.view endEditing:YES];
    _currUser.real_name = _textField.text;
    [self.delegate changeUserInfo:_currUser];
    [self.navigationController popViewControllerAnimated:YES];
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
                [self.navigationController.view showMessageTips:@"名称不能大于5个字"];
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
        }
        
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else
    {
        if (toBeString.length > MAX_STARWORDS_LENGTH)
        {
            [self.navigationController.view showMessageTips:@"名称不能大于5个字"];
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
