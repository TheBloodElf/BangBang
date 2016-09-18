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
    self.title = @"分享内容";
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction:)];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}
- (void)rightAction:(UIBarButtonItem*)item
{
    [self.navigationController.view showLoadingTips:@""];
    if([self isBlankStr:model.shareUserText]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"请填写分享内容" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController.view dismissTips];
        }];
        [alert addAction:alertAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if(model.imageData)
        [self uploadImage];
    else
        [self shareContent];
}
- (void)uploadImage {
    AFHTTPSessionManager *_uploadSessionManager;
    _uploadSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    [_uploadSessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [_uploadSessionManager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    NSString *urlPath = @"Attachments/upload_attachment";
    NSDictionary *parameters = @{@"user_guid":model.shareUserGuid,@"access_token":model.shareToken};
    [_uploadSessionManager POST:urlPath parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:model.imageData name:@"doc" fileName:[NSString stringWithFormat:@"%@.jpg",@([NSDate date].timeIntervalSince1970 * 1000)] mimeType:@"image/jpeg"];
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        model.shareImage = responseObject[@"data"][@"file_url"];
        [self shareContent];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"分享失败，请稍后再试" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController.view dismissTips];
            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
        }];
        [alert addAction:alertAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}
- (void)shareContent {
    NSMutableDictionary *parameter = [@{@"transfer_title":model.shareText,@"describe":model.shareUserText,@"company_no":model.shareCompanyNo,@"user_guid":model.shareUserGuid,@"access_token":model.shareToken} mutableCopy];
    if(![self isBlankStr:model.shareUrl]) {//有网址就分享网址
        [parameter setValue:model.shareUrl forKey:@"transfer_url"];
    }
    if(![self isBlankStr:model.shareImage]) {//有图片就分享图片
        [parameter setValue:model.shareImage forKey:@"transfer_image"];
    }
    [manager POST:@"Dynamic/share_to_dynamic" parameters:parameter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.navigationController.view dismissTips];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"分享成功" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
        }];
        [alert addAction:alertAction];
        [self presentViewController:alert animated:YES completion:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.navigationController.view dismissTips];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"分享失败，请稍后再试" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
        }];
        [alert addAction:alertAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}
- (BOOL)isBlankStr:(NSString*)str
{
    BOOL ret = NO;
    if ((str == nil)|| ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) || [str isKindOfClass:[NSNull class]])
        ret = YES;
    return ret;
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
