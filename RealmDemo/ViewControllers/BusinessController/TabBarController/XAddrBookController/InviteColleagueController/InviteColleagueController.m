//
//  InviteColleagueController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/6.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "InviteColleagueController.h"
#import "FaceInviteColleague.h"
#import "UserManager.h"
#import "UserHttp.h"

@interface InviteColleagueController () {
    UserManager *_userManager;
}

@end

@implementation InviteColleagueController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"邀请同事";
    _userManager = [UserManager manager];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark --
#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0) {//当面邀请
        FaceInviteColleague *face = [FaceInviteColleague new];
        face.providesPresentationContextTransitionStyle = YES;
        face.definesPresentationContext = YES;
        face.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:face animated:NO completion:nil];
    } else {//加入自己的圈子
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp getInviteURL:_userManager.user.user_no companyNo:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSString *shareStr = [NSString stringWithFormat:@"我是\"%@\",为了提高工作效率,\"%@\"(圈子编号:%d)最近在使用帮帮管理助手(%@),我已经加入了,你也来吧!",_userManager.user.real_name,_userManager.user.currCompany.company_name,_userManager.user.currCompany.company_no,data[@"url_short"]];
            NSURL *url = [NSURL URLWithString:@""];
            UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[shareStr,url] applicationActivities:nil];
            [self presentViewController:vc animated:YES completion:nil];
        }];
    }
}
@end
