//
//  ShareErrorController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "ShareErrorController.h"
#import "UtikIesTool.h"
@interface ShareErrorController ()

@end

@implementation ShareErrorController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = @"错误";
    UILabel * error = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, 250, 70)];
    error.text = @"你必须登录帮帮才能使用分享功能";
    error.textAlignment = NSTextAlignmentCenter;
    error.numberOfLines = 0;
    error.textColor = [UIColor grayColor];
    [self.view addSubview:error];
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    okBtn.frame = CGRectMake(0, 330 - 40, 250, 40);
    [okBtn setTitle:@"我知道了" forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(okBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)okBtnClicked:(UIButton*)btn
{
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
