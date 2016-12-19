//
//  InputTextController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/3.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "InputTextController.h"

@interface InputTextController ()<UITextViewDelegate> {
    UITextView *_textView;
    UILabel *_detileLabel;
    UIButton *okBtn;
    UIView *bottom;
}

@end

@implementation InputTextController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    UIButton *bgn = [UIButton buttonWithType:UIButtonTypeCustom];
    bgn.backgroundColor = [UIColor blackColor];
    bgn.alpha = 0.5;
    bgn.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
    [bgn addTarget:self action:@selector(exitInput:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bgn];
    
    bottom = [[UIView alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 218, MAIN_SCREEN_WIDTH, 218)];
    bottom.backgroundColor = [UIColor whiteColor];
    bottom.userInteractionEnabled = YES;
    [self.view addSubview:bottom];
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 12, MAIN_SCREEN_WIDTH - 24, 200)];
    _textView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);//让iqkeyboard自己上升到按钮以上的高度
    _textView.delegate = self;
    _textView.showsHorizontalScrollIndicator = NO;
    _textView.showsVerticalScrollIndicator = NO;
    [bottom addSubview:_textView];
    _detileLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 150, 15)];
    _detileLabel.font = [UIFont systemFontOfSize:15];
    _detileLabel.textColor = [UIColor lightGrayColor];
    _detileLabel.text = @"请写明原因...";
    [bottom addSubview:_detileLabel];
    
    okBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [okBtn setTitle:@"确认" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    okBtn.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
    okBtn.layer.cornerRadius = 5;
    okBtn.clipsToBounds = YES;
    okBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH / 2 + 20, bottom.frame.size.height - 13 - 30, 80, 30);
    [okBtn addTarget:self action:@selector(sureClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:okBtn];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancleBtn.backgroundColor = [UIColor darkGrayColor];
    cancleBtn.layer.cornerRadius = 5;
    cancleBtn.clipsToBounds = YES;
    cancleBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH / 2 - 20 - 80, bottom.frame.size.height - 13 - 30, 80, 30);
    [cancleBtn addTarget:self action:@selector(exitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottom addSubview:cancleBtn];
    // Do any additional setup after loading the view.
}
- (void)textViewDidChange:(UITextView *)textView {
    if([NSString isBlank:textView.text]) {
        _detileLabel.hidden = NO;
    } else {
        _detileLabel.hidden = YES;
    }
}
- (void)sureClicked:(UIButton*)btn {
    if([NSString isBlank:_textView.text]) {
        [self.view showMessageTips:@"请输入内容"];
        return;
    }
    if(self.inputTextBlock)
        self.inputTextBlock(_textView.text);
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)exitClicked:(UIButton*)btn {
    if(self.cancelBlock)
        self.cancelBlock();
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)exitInput:(UIButton*)btn {
    [[IQKeyboardManager sharedManager] resignFirstResponder];
}
@end
