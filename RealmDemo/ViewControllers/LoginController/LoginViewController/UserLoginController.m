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
#import "WeiboUser.h"
#import "UserManager.h"
#import "IdentityHttp.h"

@interface UserLoginController ()<TencentSessionDelegate,WXApiManagerDeleagate,WBApiManagerDelegate> {
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
    [WXApiManager sharedManager].delegate = self;
    [WBApiManager shareManager].delegate = self;
    //把视图移动到最顶部 即使有状态栏和导航
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
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
        [self.navigationController showLoadingTips:@"登录..."];
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
    SendAuthReq *req = [[SendAuthReq alloc]init];
    req.scope = @"snsapi_base,snsapi_userinfo";
    req.state = @"bangbang";
    req.openID = @"wxbd349c9a6abf20f8";
    [WXApi sendAuthReq:req viewController:self delegate:[WXApiManager sharedManager]];
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
#pragma mark - WXApiManagerDeleagate
-(void)managerDidRecvAuthResponse:(SendAuthResp *)response {
    if (response.errCode == 0) {
        [self getAccessTokenWeiXin:response.code];
    } else {
        [self.navigationController.view showMessageTips:@"微信授权失败"];
    }
}
 //获取微信token
- (void)getAccessTokenWeiXin:(NSString*)codeWeixin {
     NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",@"wxbd349c9a6abf20f8",@"30068a0f26955393f85428d97fece628",codeWeixin];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlStr];
        NSString *requestStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(data){
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *accessTokenWeiXin = [dic objectForKey:@"access_token"];
                NSString *openIdWeiXin = [dic objectForKey:@"openid"];
                NSString *expiresWeixin = [dic objectForKey:@"expires_in"];
                if (accessTokenWeiXin&&openIdWeiXin) {
                    //获取微信用户信息
                    [self getWXUserInfo:accessTokenWeiXin openID:openIdWeiXin expiresWeixin:expiresWeixin];
                }else{
                    [self.navigationController.view showMessageTips:@"微信授权失败"];
                }
            }
        });
    });
}
//获取微信用户信息
- (void)getWXUserInfo:(NSString*)accessToken openID:(NSString*)openIdWeiXin expiresWeixin:(NSString*)expiresWeixin {
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openIdWeiXin];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:urlStr];
        NSString *requestStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSString *userName = [dic objectForKey:@"nickname"];
                NSString *userAvatar = [dic objectForKey:@"headimgurl"];
                NSString *unionId = [dic objectForKey:@"unionid"];
                if (userName && userAvatar) {
                    //获取accessToken
                    [self.navigationController.view showLoadingTips:@"获取token..."];
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
                        [self.navigationController.view showLoadingTips:@"登录..."];
                        [UserHttp socialLogin:unionId media_type:@"weixin" token:accessToken expires_in:expiresWeixin client_type:@"ios" name:userName avatar_url:userAvatar handler:^(id data, MError *error) {
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
                }else{
                    [self.navigationController.view showMessageTips:@"获取微信用户信息失败"];
                }
            }
        });
    });
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
    WBAuthorizeRequest *  request = [WBAuthorizeRequest request];
    request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"bangbang",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}
#pragma mark -- WBApiManagerDelegate
-(void)managerDidRecvResponse:(WBAuthorizeResponse *)response{
    NSString *accessTokenWeiBo = response.accessToken;
    NSDate *expirationDate = response.expirationDate;
    NSTimeInterval interval = [expirationDate timeIntervalSinceNow];
    long intervalLong = interval;
    NSString *expiresWeiBo = [NSString stringWithFormat:@"%ld",intervalLong];
    NSString *currentUserId = response.userID;
    
    [WBHttpRequest requestForUserProfile:currentUserId withAccessToken:accessTokenWeiBo andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest,id result,NSError *error){
        if (error) {
            [self.navigationController.view showMessageTips:@"微博获取用户信息失败！"];
        }else{
            WeiboUser *user = (WeiboUser *)result;
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
                [self.navigationController showLoadingTips:@"登录..."];
                [UserHttp socialLogin:user.userID media_type:@"weibo" token:accessTokenWeiBo expires_in:expiresWeiBo client_type:@"ios" name:user.name avatar_url:user.avatarLargeUrl handler:^(id data, MError *error) {
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
            }];
        }
    }];
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
