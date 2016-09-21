//
//  AboutViewController.m
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AboutViewController.h"
#import "WebNonstandarViewController.h"
#import "EAIntroViewController.h"
#import "IdentityManager.h"
#import "IdentityHttp.h"

@interface AboutViewController ()<EAIntroViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于帮帮";
    //添加当前版本号信息
    NSString *currentVerson = [NSString stringWithFormat:@"v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    if([KBSSDKAPIDomain rangeOfString:@"test"].location != NSNotFound) {
        currentVerson = [currentVerson stringByAppendingString:@" 测试环境"];
    }
    self.versionLabel.text = currentVerson;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
//产品介绍
- (IBAction)ealntroClicked:(id)sender {
    EAIntroViewController *view = [EAIntroViewController new];
    view.delegate = self;
    [self presentViewController:view animated:NO completion:nil];
}
//去评分
- (IBAction)gotoAppStore:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=979426412&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
}
//检查更新
- (IBAction)checkSoftUpdate:(id)sender {
    [self.navigationController.view showLoadingTips:@""];
    [IdentityHttp getSoftVersionHandler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSString *appStoreVersion = data;
        NSString *currVersion = [IdentityManager manager].identity.lastSoftVersion;
        //比较版本号是否一样
        if([appStoreVersion isEqualToString:currVersion]) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"当前已是最新版本，无需更新" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertVC addAction:okAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        } else {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"发现新版本，是否更新" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=979426412&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8"]];
            }];
            [alertVC addAction:okAction];
            UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:cancleAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }];
}

#pragma mark --
#pragma mark -- EAIntroViewDelegate
- (void)eAIntroViewDidFinish:(EAIntroViewController *)eAIntro {
    [eAIntro dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)helpClicked:(id)sender {
    //常见问题
    WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
    webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@common/terms",BBHOMEURL];
    webViewcontroller.showNavigationBar = YES;
    webViewcontroller.title = @"使用条款";
    [self.navigationController pushViewController:webViewcontroller animated:YES];
}
@end
