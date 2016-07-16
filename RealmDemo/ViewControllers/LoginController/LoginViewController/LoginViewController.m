//
//  LoginViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//
//在这个界面应该把登录信息和用户表都创建好
#import "LoginViewController.h"
#import "IdentityManager.h"
#import "IdentityHttp.h"
#import "UserManager.h"
#import "UserHttp.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountFiexd;
@property (weak, nonatomic) IBOutlet UITextField *passwordFiexd;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户登录";
}
- (IBAction)loginClicked:(id)sender {
    //判断值是否填满
    if([NSString isBlank:self.accountFiexd.text]) {
        [self.navigationController.view showFailureTips:@"请输入账号"];
        return;
    }
    if([NSString isBlank:self.passwordFiexd.text]) {
        [self.navigationController.view showFailureTips:@"请输入密码"];
        return;
    }
    //看存不存在accessToken，不存在就获取
    IdentityManager *manager = [IdentityManager manager];
    if([NSString isBlank:manager.identity.accessToken]) {
        [self.navigationController showLoadingTips:@"请稍等..."];
        [IdentityHttp getAccessTokenhandler:^(id data, MError *error) {
            if(error) {
                [self.navigationController dismissTips];
                [self.navigationController.view showFailureTips:@"登录失败，请重试"];
                return ;
            }
            NSString *accessToken = data[@"access_token"];
            manager.identity.accessToken = accessToken;
            [manager saveAuthorizeData];
            //进入登录程序
            [self gotoLogin];
        }];
    } else {
        [self gotoLogin];
    }
}
//进入登录程序
- (void)gotoLogin {
    [self.navigationController showLoadingTips:@"请稍等..."];
    [IdentityHttp loginWithEmail:self.accountFiexd.text password:self.passwordFiexd.text handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        //加入用户数据库
        User *user = [[User alloc] initWithJsonDic:data];
        UserManager *manager = [UserManager manager];
        [manager loadUserWithGuid:user.user_guid];
        //加入圈子到数据库
        NSMutableArray *companys = [@[] mutableCopy];
        for (NSDictionary *tempDic in data[@"user_companies"]) {
            Company *company = [Company new];
            [company mj_setKeyValues:tempDic];
            [companys addObject:company];
        }
        [manager updateCompanyArr:companys];
        //初始化第一个圈子为用户当前圈子
        if(companys.count)
            user.currCompany = companys[0];
        [manager updateUser:user];
        //更换登录信息
        IdentityManager *identityManager = [IdentityManager manager];
        identityManager.identity.user_guid = user.user_guid;
        [identityManager saveAuthorizeData];
        //获取所有圈子的员工信息
        [UserHttp getEmployeeCompnyNo:0 status:-1 userGuid:user.user_guid handler:^(id data, MError *error) {
            [self.navigationController dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:@"登陆失败，请重试"];
                return ;
            }
            NSMutableArray *array = [@[] mutableCopy];
            for (NSDictionary *dic in data[@"list"]) {
                Employee *employee = [Employee new];
                [employee mj_setKeyValues:[dic mj_keyValues]];
                [array addObject:employee];
            }
            //存入本地数据库
            [manager updateEmployee:array companyNo:0];
            //发通知 登录成功
            [self.navigationController showSuccessTips:@"登录成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginDidFinish" object:nil];
        }];
    }];
}
@end
