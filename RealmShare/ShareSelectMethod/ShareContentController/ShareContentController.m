//
//  ShareContentController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "ShareContentController.h"
#import "ShareModel.h"
#import "UtikIesTool.h"
#import "ShareContentTopCell.h"
@interface ShareContentController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    ShareModel *model;
    AFHTTPSessionManager *manager;
}
@end

@implementation ShareContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    model = [ShareModel shareInstance];
    manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 250, 330) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.showsVerticalScrollIndicator = NO;
    [_tableView registerNib:[UINib nibWithNibName:@"ShareContentTopCell" bundle:nil] forCellReuseIdentifier:@"ShareContentTopCell"];
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    self.title = @"分享内容";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction:)];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}
- (void)rightAction:(UIBarButtonItem*)item
{
    [self.navigationController.view showLoadingTips:@""];
    NSMutableDictionary *parameter = [@{@"transfer_url":model.shareUrl,@"company_no":model.shareCompanyNo,@"user_guid":model.shareUserGuid,@"access_token":model.shareToken} mutableCopy];
    if(![self isBlankStr:model.shareImage])
        [parameter setObject:model.shareImage forKey:@"transfer_image"];
    if(![self isBlankStr:model.shareUserText])
        [parameter setObject:model.shareUserText forKey:@"describe"];
    if(![self isBlankStr:model.shareText])
        [parameter setObject:model.shareText forKey:@"transfer_title"];
    [manager POST:@"Dynamic/share_to_dynamic" parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.navigationController.view dismissTips];
        [self showMessage:@"分享成功"];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.navigationController.view dismissTips];
        [self showMessage:@"分享失败，请稍后再试"];
    }];
    
}
- (BOOL)isBlankStr:(NSString*)str
{
    BOOL ret = NO;
    if ((str == nil)|| ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) || [str isKindOfClass:[NSNull class]])
        ret = YES;
    return ret;
}
- (void)showMessage:(NSString*)str
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    }];
    [alert addAction:alertAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark --
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShareContentTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShareContentTopCell" forIndexPath:indexPath];
    return cell;
}
#pragma mark --
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 336.f;
}
@end
