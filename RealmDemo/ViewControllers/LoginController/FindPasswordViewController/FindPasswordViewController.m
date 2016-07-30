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

@end

@implementation FindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"找回密码";
    _webView  = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    NSURL *nsurl =[NSURL URLWithString:[NSString stringWithFormat:@"%@user/find",BBHOMEURL]];
    NSURLRequest *request =[NSURLRequest requestWithURL:nsurl];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    
    [WebViewJavascriptBridge enableLogging];
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
@end
