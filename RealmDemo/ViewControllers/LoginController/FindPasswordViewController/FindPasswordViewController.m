//
//  FindPasswordViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "FindPasswordViewController.h"

@interface FindPasswordViewController ()<UIWebViewDelegate> {
    UIWebView *_webView;
}
@property (nonatomic,strong) WebViewJavascriptBridge *bridge;//交互中间件

@end

@implementation FindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"找回密码";
    _webView  = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64)];
    NSURL *nsurl =[NSURL URLWithString:[NSString stringWithFormat:@"%@user/find?needPushNoti=NO",BBHOMEURL]];
    NSURLRequest *request =[NSURLRequest requestWithURL:nsurl];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    //开始绑定交互
    [WebViewJavascriptBridge enableLogging];
    //初始化WebViewJavascriptBridge
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    //返回上一页
    [_bridge registerHandler:@"findPasswordFinish" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self.navigationController popViewControllerAnimated:YES];
        responseCallback(@"Response from testObjcCallback");
    }];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark --- UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.navigationController.view showLoadingTips:@""];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.navigationController.view dismissTips];
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.navigationController.view dismissTips];
    [self.navigationController.view showFailureTips:@"网络出错了"];
}
@end
