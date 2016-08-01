//
//  ShareContentTopCell.m
//  BangBang
//
//  Created by haigui on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "ShareContentTopCell.h"
#import "UIImageView+WebCache.h"
#import "ShareModel.h"
@interface ShareContentTopCell  ()<UITextViewDelegate,UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITextView *text;
@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *phLabel;//占位符号
@end

@implementation ShareContentTopCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.webView.hidden = YES;
    [self.contentView addSubview:self.webView];
    self.text.delegate = self;
    self.webView.delegate = self;
    [self setModel];
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    ShareModel *model = [ShareModel shareInstance];
    model.shareUserText = textView.text;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    if([self isBlankStr:textView.text])
        self.phLabel.hidden = NO;
    else
        self.phLabel.hidden = YES;
}
- (void)setModel
{
    ShareModel *model = [ShareModel shareInstance];
    if([self isBlankStr:model.shareText])
        model.shareText = @"分享内容";
    self.title.text = model.shareText;
    self.text.text = model.shareUserText;
    if([self isBlankStr:model.shareUserText])
        self.phLabel.hidden = NO;
    else
        self.phLabel.hidden = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.shareUrl]];
    [self.webView loadRequest:request];
}
- (BOOL)isBlankStr:(NSString*)str
{
    BOOL ret = NO;
    if ((str == nil)|| ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) || [str isKindOfClass:[NSNull class]])
        ret = YES;
    return ret;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    ShareModel *model = [ShareModel shareInstance];
    NSString *imageUrl = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.getElementsByTagName(\"img\")[0].src"];
    if(![self isBlankStr:imageUrl])
        model.shareImage = imageUrl;
    else
        model.shareImage = @"http://mobile.59bang.com/content/i/bangbang_log.png";
    [self.image sd_setImageWithURL:[NSURL URLWithString:model.shareImage] placeholderImage:[UIImage imageNamed:@"appicon"]];
}

@end
