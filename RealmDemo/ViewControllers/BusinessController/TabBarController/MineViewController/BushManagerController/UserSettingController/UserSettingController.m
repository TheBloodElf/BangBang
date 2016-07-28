//
//  UserSettingController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/26.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "UserSettingController.h"
#import "IdentityManager.h"
#import "UserHttp.h"
#import "SelectDateController.h"
#import "WebNonstandarViewController.h"
#import "UserManager.h"
//时间选择器的高度
#define dataPickerViewHeight  200

@interface UserSettingController ()
{
    UserManager *_userManager;//用户管理器
    IdentityManager *_identityManager;//登陆信息管理器
}

@property (weak, nonatomic) IBOutlet UISwitch *messageSwitch;//新消息是否展开
@property (weak, nonatomic) IBOutlet UISwitch *voiceSwitch;//声音开关
@property (weak, nonatomic) IBOutlet UISwitch *vibrateSwitch;//振动开关
@property (weak, nonatomic) IBOutlet UISwitch *messageNoSwitch;//免打扰是否展开
@property (weak, nonatomic) IBOutlet UILabel *beginTime;//免打扰开始时间
@property (weak, nonatomic) IBOutlet UILabel *endTime;//免打扰结束时间

@end

@implementation UserSettingController
#pragma mark --
#pragma mark -- ControllerLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设置";
    _userManager = [UserManager manager];
    _identityManager = [IdentityManager manager];
    //获取存储的需要屏蔽的开始时间和结束时间  服务器没有存储 只有自己本地来了
    BOOL messageNoBool = _identityManager.identity.ryDisturb;
    self.messageSwitch.on = ![[RCIM sharedRCIM] disableMessageNotificaiton];
    self.messageNoSwitch.on = messageNoBool;
    //初始化开始显示的值
    self.voiceSwitch.on = _identityManager.identity.canPlayVoice != 1;
    self.vibrateSwitch.on = _identityManager.identity.canPlayShake != 1;
    self.beginTime.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)_identityManager.identity.ryDisturbBeginTime.hour,(long)_identityManager.identity.ryDisturbBeginTime.minute];
    self.endTime.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)_identityManager.identity.ryDisturbEndTime.hour,(long)_identityManager.identity.ryDisturbEndTime.minute];
    [self.tableView reloadData];
    //添加开关事件
    [_messageSwitch addTarget:self action:@selector(messageClicked:) forControlEvents:UIControlEventValueChanged];
    [_voiceSwitch addTarget:self action:@selector(voiceClicked:) forControlEvents:UIControlEventValueChanged];
    [_vibrateSwitch addTarget:self action:@selector(vibrateClicked:) forControlEvents:UIControlEventValueChanged];
    [_messageNoSwitch addTarget:self action:@selector(messageNoClicked:) forControlEvents:UIControlEventValueChanged];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
//新消息开关被点击
- (void)messageClicked:(UISwitch*)sw
{
    [[RCIM sharedRCIM] setDisableMessageNotificaiton:!sw.on];
    [self.tableView reloadData];
}
//声音开关被点击
- (void)voiceClicked:(UISwitch*)sw
{
    //存到本地 同时调用融云的接口
    _identityManager.identity.canPlayVoice = sw.on;
    [_identityManager saveAuthorizeData];
    [[RCIM sharedRCIM] setDisableMessageAlertSound:!sw.on];
}
//震动开关被点击
- (void)vibrateClicked:(UISwitch*)sw
{
    _identityManager.identity.canPlayShake = sw.on;
    [_identityManager saveAuthorizeData];
}
//消息免打扰开关被点击
- (void)messageNoClicked:(UISwitch*)sw
{
    //存到本地 同时调用融云的接口  免打扰融云有接口，开始还说怎么做呢。。。
    _identityManager.identity.ryDisturb = sw.on;
    [_identityManager saveAuthorizeData];
    if(_identityManager.identity.ryDisturb) {//设置免打扰
        int intt = [@([_identityManager.identity.ryDisturbEndTime timeIntervalSinceDate:_identityManager.identity.ryDisturbBeginTime] / 60.f) intValue];
        if(intt == 0)
            intt = 1;
        [[RCIMClient sharedRCIMClient] setNotificationQuietHours:[NSString stringWithFormat:@"%02ld:%02ld:00",(long)_identityManager.identity.ryDisturbBeginTime.hour,(long)_identityManager.identity.ryDisturbBeginTime.minute] spanMins:intt success:nil error:nil];
    } else {//取消免打扰
        [[RCIMClient sharedRCIMClient] removeNotificationQuietHours:nil error:nil];
    }
    [self.tableView reloadData];
}
//清除聊天记录
- (void)clearChatNote
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定要清除聊天记录?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[RCIMClient sharedRCIMClient] clearConversations:@[@(1),@(2),@(3)]];
        [self.navigationController.view showSuccessTips:@"聊天记录清理成功!"];
    }];
    [alertVC addAction:alertCancel];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//清除缓存
- (void)clearCache
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定要清除缓存?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController.view showSuccessTips:@"缓存清理成功!"];
    }];
    [alertVC addAction:alertCancel];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//清除通知
- (void)clearNotifotion
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定要清除通知?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:alertCancel];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//推荐给好友
- (void)recommendToFriend
{
    [self.navigationController.view showLoadingTips:@""];
    //获取邀请链接
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
}
//账号安全
- (void)accountSafe
{
    WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
    webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@/security/index?userGuid=%@&access_token=%@&companyNo=%ld",XYFMobileDomain,_userManager.user.user_guid,_identityManager.identity.accessToken,_userManager.user.currCompany.company_no];
    [self.navigationController pushViewController:webViewcontroller animated:YES];
}
//退出帮帮
- (void)exitSoft
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确定要退出回到登陆界面?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_identityManager showLogin];
    }];
    [alertVC addAction:alertCancel];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];
}
#pragma mark -- 
#pragma mark -- TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //这里有个小技巧 高度返回0.01f这样就达到了qq好友分组头部点击的效果
    CGFloat rowHeight = 44.f;
    if(indexPath.section == 1) {
        if(indexPath.row == 2 || indexPath.row == 1) {
            if([[RCIM sharedRCIM] disableMessageNotificaiton] == YES)
                rowHeight = 0.01f;
        }
        if(indexPath.row == 5 || indexPath.row == 4) {
            if(_identityManager.identity.ryDisturb == NO)
                rowHeight = 0.01f;
        }
        if(indexPath.row == 3)
            return 88.f;
    }
    return rowHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //根据下表判断 处理事件
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            [self clearChatNote];
        } else if (indexPath.row == 1) {
            [self clearCache];
        } else {
            [self clearNotifotion];
        }
    } else if (indexPath.section == 1) {
        if(indexPath.row == 4) {
            //选择开始时间
            SelectDateController *select = [SelectDateController new];
            select.datePickerMode = UIDatePickerModeTime;
            select.selectDateBlock = ^(NSDate *date) {
                _identityManager.identity.ryDisturbBeginTime = date;
                [_identityManager saveAuthorizeData];
                if(_identityManager.identity.ryDisturb) {
                    int intt = [@([_identityManager.identity.ryDisturbEndTime timeIntervalSinceDate:_identityManager.identity.ryDisturbBeginTime] / 60.f) intValue];
                    if(intt == 0)
                        intt = 1;
                    [[RCIMClient sharedRCIMClient] setNotificationQuietHours:[NSString stringWithFormat:@"%02ld:%02ld:00",(long)_identityManager.identity.ryDisturbBeginTime.hour,(long)_identityManager.identity.ryDisturbBeginTime.minute] spanMins:intt success:nil error:nil];
                }
                _beginTime.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)_identityManager.identity.ryDisturbBeginTime.hour,(long)_identityManager.identity.ryDisturbBeginTime.minute];
            };
            select.providesPresentationContextTransitionStyle = YES;
            select.definesPresentationContext = YES;
            select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:select animated:NO completion:nil];
        } else if (indexPath.row == 5) {
            //选择结束时间
            SelectDateController *select = [SelectDateController new];
            select.datePickerMode = UIDatePickerModeTime;
            select.selectDateBlock = ^(NSDate *date) {
                _identityManager.identity.ryDisturbEndTime = date;
                [_identityManager saveAuthorizeData];
                if(_identityManager.identity.ryDisturb) {
                    int intt = [@([_identityManager.identity.ryDisturbEndTime timeIntervalSinceDate:_identityManager.identity.ryDisturbBeginTime] / 60.f) intValue];
                    if(intt == 0)
                        intt = 1;
                    [[RCIMClient sharedRCIMClient] setNotificationQuietHours:[NSString stringWithFormat:@"%02ld:%02ld:00",(long)_identityManager.identity.ryDisturbBeginTime.hour,(long)_identityManager.identity.ryDisturbBeginTime.minute] spanMins:intt success:nil error:nil];
                }
                _endTime.text = [NSString stringWithFormat:@"%02ld:%02ld",(long)_identityManager.identity.ryDisturbEndTime.hour,(long)_identityManager.identity.ryDisturbEndTime.minute];
            };
            select.providesPresentationContextTransitionStyle = YES;
            select.definesPresentationContext = YES;
            select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:select animated:NO completion:nil];
        }
    } else if (indexPath.section == 2) {
        if(indexPath.row == 0) {
            [self recommendToFriend];
        } else {
            [self accountSafe];
        }
    } else {
        [self exitSoft];
    }
}
@end
