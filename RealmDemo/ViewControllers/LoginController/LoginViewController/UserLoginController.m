//
//  UserLoginController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/27.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//
//登录
#import "UserLoginController.h"
#import "FindPasswordViewController.h"
#import "RegisterViewController.h"
#import "IdentityManager.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "IdentityHttp.h"

@interface UserLoginController ()<TencentSessionDelegate> {
    UserManager *_userManager;
    IdentityManager *_identityManager;
    
    TencentOAuth *_tencentOAuth;//QQ登录认证
}
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *qqLoginBtn;
@end

@implementation UserLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserManager manager];
    _identityManager = [IdentityManager manager];
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1103790262" andDelegate:self];
    if(![TencentOAuth iphoneQQInstalled]) {
        self.qqLoginBtn.hidden = YES;
    }
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
//账号密码登录
- (IBAction)palinLoginClicked:(id)sender {
    //判断值是否填满
    if([NSString isBlank:self.accountField.text]) {
        [self.navigationController.view showFailureTips:@"请输入账号"];
        return;
    }
    if([NSString isBlank:self.passwordField.text]) {
        [self.navigationController.view showFailureTips:@"请输入密码"];
        return;
    }
    //获取token
    [self.navigationController showLoadingTips:@"获取token..."];
    [IdentityHttp getAccessTokenhandler:^(id data, MError *error) {
        if(error) {
            [self.navigationController dismissTips];
            [self.navigationController.view showFailureTips:@"登录失败，请重试"];
            return ;
        }
        NSString *accessToken = data[@"access_token"];
        _identityManager.identity.accessToken = accessToken;
        [_identityManager saveAuthorizeData];
        //登录
        [self.navigationController showLoadingTips:@"登录token..."];
        [IdentityHttp loginWithEmail:self.accountField.text password:self.passwordField.text handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController dismissTips];
                _identityManager.identity.user_guid = @"";
                [_identityManager saveAuthorizeData];
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            User *user = [[User alloc] initWithJsonDic:data];
            UserManager *manager = [UserManager manager];
            [manager loadUserWithGuid:user.user_guid];
            NSMutableArray *companys = [@[] mutableCopy];
            for (NSDictionary *tempDic in data[@"user_companies"]) {
                Company *company = [Company new];
                [company mj_setKeyValues:tempDic];
                [companys addObject:company];
            }
            [manager updateCompanyArr:companys];
            [manager updateUser:user];
            _identityManager.identity.user_guid = user.user_guid;
            [_identityManager saveAuthorizeData];
            //获取所有圈子的员工信息
            [self.navigationController showLoadingTips:@"获取员工信息..."];
            [UserHttp getEmployeeCompnyNo:0 status:5 userGuid:user.user_guid handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController dismissTips];
                    _identityManager.identity.user_guid = @"";
                    [_identityManager saveAuthorizeData];
                    [self.navigationController.view showFailureTips:@"登陆失败，请重试"];
                    return ;
                }
                NSMutableArray *array = [@[] mutableCopy];
                for (NSDictionary *dic in data[@"list"]) {
                    Employee *employee = [Employee new];
                    [employee mj_setKeyValues:[dic mj_keyValues]];
                    [array addObject:employee];
                }
                [manager updateEmployee:array companyNo:0];
                //获取融云token
                [self.navigationController showLoadingTips:@"获取token..."];
                [UserHttp getRYToken:user.user_no handler:^(id data, MError *error) {
                    [self.navigationController dismissTips];
                    if(error) {
                        _identityManager.identity.user_guid = @"";
                        [_identityManager saveAuthorizeData];
                        [self.navigationController.view showFailureTips:@"登陆失败，请重试"];
                        return ;
                    }
                    _identityManager.identity.RYToken = data;
                    [_identityManager saveAuthorizeData];
                    [self.navigationController.view showFailureTips:@"登陆成功"];
                    //发通知 登录成功
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginDidFinish" object:nil];
                }];
            }];
        }];
    }];
}
//微信登录
- (IBAction)wxLoginClicked:(id)sender {
    
}
//QQ登录
- (IBAction)qqLoginClicked:(id)sender {
//    获取token
    [self.navigationController.view showLoadingTips:@"获取token..."];
    [IdentityHttp getAccessTokenhandler:^(id data, MError *error) {
        [self.navigationController dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:@"失败，请重试"];
            return ;
        }
        NSString *accessToken = data[@"access_token"];
        _identityManager.identity.accessToken = accessToken;
        [_identityManager saveAuthorizeData];
        //获取QQ用户信息
        NSArray* permissions =  [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo", nil];
        [_tencentOAuth authorize:permissions inSafari:NO];
    }];
}
#pragma mark --
#pragma mark -- TencentSessionDelegate
- (void)tencentDidLogin
{
    [self.navigationController.view showLoadingTips:@"获取QQ信息..."];
    [_tencentOAuth getUserInfo];
}
-(void)getUserInfoResponse:(APIResponse *)response
{
    NSString *avatar = [response.jsonResponse objectForKey:@"figureurl_qq_1"];
    NSString *name = [response.jsonResponse objectForKey:@"nickname"];
    long exptime = [[_tencentOAuth expirationDate] timeIntervalSinceDate:[NSDate date]];
//    登录
    [self.navigationController.view showLoadingTips:@"登录..."];
    [UserHttp socialLogin:[_tencentOAuth openId] media_type:@"qq" token:[_tencentOAuth accessToken] expires_in:[NSString stringWithFormat:@"%ld",exptime] client_type:@"ios" name:name avatar_url:avatar handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        User *user = [[User alloc] initWithJsonDic:data];
        UserManager *manager = [UserManager manager];
        [manager loadUserWithGuid:user.user_guid];
        NSMutableArray *companys = [@[] mutableCopy];
        for (NSDictionary *tempDic in data[@"user_companies"]) {
            Company *company = [Company new];
            [company mj_setKeyValues:tempDic];
            [companys addObject:company];
        }
        [manager updateCompanyArr:companys];
        [manager updateUser:user];
        _identityManager.identity.user_guid = user.user_guid;
        [_identityManager saveAuthorizeData];
        //获取所有圈子员工
        [self.navigationController.view showLoadingTips:@"获取员工信息..."];
        [UserHttp getEmployeeCompnyNo:0 status:5 userGuid:user.user_guid handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController dismissTips];
                _identityManager.identity.user_guid = @"";
                [_identityManager saveAuthorizeData];
                [self.navigationController.view showFailureTips:@"登陆失败，请重试"];
                return ;
            }
            NSMutableArray *array = [@[] mutableCopy];
            for (NSDictionary *dic in data[@"list"]) {
                Employee *employee = [Employee new];
                [employee mj_setKeyValues:[dic mj_keyValues]];
                [array addObject:employee];
            }
            [manager updateEmployee:array companyNo:0];
            //获取融云token
            [self.navigationController.view showLoadingTips:@"获取token..."];
            [UserHttp getRYToken:user.user_no handler:^(id data, MError *error) {
                [self.navigationController dismissTips];
                if(error) {
                    _identityManager.identity.user_guid = @"";
                    [_identityManager saveAuthorizeData];
                    [self.navigationController.view showFailureTips:@"登陆失败，请重试"];
                    return ;
                }
                _identityManager.identity.RYToken = data;
                [_identityManager saveAuthorizeData];
                [self.navigationController.view showFailureTips:@"登陆成功"];
                //发通知 登录成功
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginDidFinish" object:nil];
            }];
        }];
    }];
}
//微博登录
- (IBAction)wbLoginClicked:(id)sender {
    
}
//忘记密码
- (IBAction)forgetPassowrdClicked:(id)sender {
    FindPasswordViewController *find = [FindPasswordViewController new];
    [self.navigationController pushViewController:find animated:YES];
}
//注册
- (IBAction)registerClicked:(id)sender {
    RegisterViewController *find = [RegisterViewController new];
    [self.navigationController pushViewController:find animated:YES];
}

@end
