//
//  MineViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/14.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MineViewController.h"
#import "BushManageViewController.h"
#import "UserManager.h"
#import "UserSettingController.h"
#import "AboutViewController.h"
#import "WebNonstandarViewController.h"
#import "IdentityManager.h"
#import "UserHttp.h"

@interface MineViewController ()<RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;
    RBQFetchedResultsController *_userFetchedResultsController;
}

@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userMood;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //把视图移动到最顶部 即使有状态栏和导航
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    _userManager = [UserManager manager];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    User *user = _userManager.user;
    self.avaterImage.layer.cornerRadius = 30.f;
    self.avaterImage.clipsToBounds = YES;
    [self.avaterImage sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.userName.text = [NSString stringWithFormat:@"%@(%@)",user.real_name,@(user.user_no)];
    self.userMood.text = user.mood;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor homeListColor];
}
#pragma mark -- 
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    User *user = _userManager.user;
    [self.avaterImage sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.userName.text = [NSString stringWithFormat:@"%@(%@)",user.real_name,@(user.user_no)];
    self.userMood.text = user.mood;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {
        
    } else if (indexPath.section == 1) {
        if(indexPath.row == 0) {
            //圈子管理
            BushManageViewController *bushManager = [BushManageViewController new];
            bushManager.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:bushManager animated:YES];
        } else {
            //我的工单
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@workorder?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        }
    } else if (indexPath.section == 2) {
        //推荐给好友
        //获取邀请链接
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp getInviteURL:_userManager.user.user_no companyNo:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSString *shortUrl = data[@"url_short"];
            NSString *title = [NSString stringWithFormat:@"我是\"%@\"，为了提高工作效率，最近在使用帮帮管理助（%@），你也来吧！",_userManager.user.real_name,shortUrl];
            NSURL *url = [NSURL URLWithString:@""];
            UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[title,url] applicationActivities:nil];
            [self presentViewController:vc animated:YES completion:nil];
        }];
    } else if (indexPath.section == 3) {
        if(indexPath.row == 0) {
            //用户设置
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"MineView" bundle:nil];
            UserSettingController *user = [story instantiateViewControllerWithIdentifier:@"UserSettingController"];
            user.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:user animated:YES];
        } else {
            //常见问题
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@feedback?userGuid=%@&access_token=%@&companyNo=%ld",XYFMobileDomain,_userManager.user.user_guid,[IdentityManager manager].identity.accessToken,_userManager.user.currCompany.company_no];
            webViewcontroller.showNavigationBar = YES;
            webViewcontroller.title = @"常见问题";
            webViewcontroller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        }
    } else {
        //关于帮帮
        AboutViewController *about = [AboutViewController new];
        about.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:about animated:YES];
    }
}
@end
