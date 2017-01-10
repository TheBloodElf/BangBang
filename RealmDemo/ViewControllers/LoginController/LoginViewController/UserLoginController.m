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
//最开始的设计是登陆时依次：accessToken->login->companys->employees->RYToken
//但是这样的话登陆速度就有点慢
//现在的设计是：accessToken->login->RYToken
//然后在每次进入MainBusinessController时获取：companys->employees
//这样设计可以让登陆速度更快，而且每次进应用都能得到最新的圈子和员工信息，权衡后选择此方案

@interface UserLoginController ()<TencentSessionDelegate> {
    UserManager *_userManager;
    IdentityManager *_identityManager;
    TencentOAuth *_tencentOAuth;//QQ登录认证
}
@property (weak, nonatomic) IBOutlet UITextField *accountField;//账号输入框
@property (weak, nonatomic) IBOutlet UITextField *passwordField;//密码输入框
@property (weak, nonatomic) IBOutlet UIButton *okBtn;//登陆按钮
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thridLoginTop;//让三方登陆那一排按钮下面居中
@property (weak, nonatomic) IBOutlet UIButton *wxLogin;//微信登陆
@property (weak, nonatomic) IBOutlet UIButton *qqLogin;//qq登陆
@property (weak, nonatomic) IBOutlet UIButton *wbLogin;//微博登陆
@property (weak, nonatomic) IBOutlet UILabel *otherLogin;//三方登陆标签

@end

@implementation UserLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载用户信息管理器
    _userManager = [UserManager manager];
    //加载登陆信息管理器
    _identityManager = [IdentityManager manager];
    //初始化qq三方登陆
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1103790262" andDelegate:self];
    // 设置占位文字的颜色为红色
    [_accountField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    //把视图移动到最顶部 即使有状态栏和导航
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    //使用ARC来限制提交按钮是否能被点击
    RAC(self.okBtn, enabled) = [RACSignal combineLatest:@[self.accountField.rac_textSignal,self.passwordField.rac_textSignal] reduce:^(NSString *account,NSString *password){
        if([NSString isBlank:account])
            return @(NO);
        if([NSString isBlank:password])
            return @(NO);
        return @(YES);
    }];
    //让三方登陆按钮在下面居中显示
    _thridLoginTop.constant = (MAIN_SCREEN_HEIGHT - 369 - 37 - 45) / 2.f;
    //加上微博三方登陆的通知（appdelegate传过来）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wbDidRecvResponse:) name:@"WBApiDelegate" object:nil];
    //加上微信三方登陆的通知（appdelegate传过来）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxDidRecvResponse:) name:@"WXApiDelegate" object:nil];
    //判断三方登陆是否可用
    int count = 0;//有几个三方登陆没有安装
    if(![WeiboSDK isWeiboAppInstalled]) {
        self.wbLogin.hidden = YES;
        count ++;
    }
    if(![WXApi isWXAppInstalled]) {
        self.wxLogin.hidden = YES;
        count ++;
    }
    if(![TencentOAuth iphoneQQInstalled]) {
        self.qqLogin.hidden = YES;
        count ++;
    }
    //三个三方都没有安装就去掉"第三方登陆"提示
    if(count == 3)
        self.otherLogin.hidden = YES;
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
#pragma mark --
#pragma mark -- 账号密码登录
- (IBAction)palinLoginClicked:(id)sender {
    [self.view endEditing:YES];
    //获取token
    [self.navigationController showLoadingTips:@""];
    [IdentityHttp getAccessTokenhandler:^(id data, MError *error) {
        if(error) {
            [self.navigationController dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSString *accessToken = data[@"access_token"];
        _identityManager.identity.accessToken = accessToken;
        [_identityManager saveAuthorizeData];
        //登录
        [IdentityHttp loginWithEmail:self.accountField.text password:self.passwordField.text handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController dismissTips];
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            User *user = [User new];
            [user mj_setKeyValues:data];
            [_userManager loadUserWithGuid:user.user_guid];
            //获取融云token
            [UserHttp getRYToken:user.user_no handler:^(id data, MError *error) {
                [self.navigationController dismissTips];
                if(error) {
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                user.RYToken = data;
                [_userManager updateUser:user];
                _identityManager.identity.user_guid = user.user_guid;
                [_identityManager saveAuthorizeData];
                //发通知 登录成功
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginDidFinish" object:nil];
            }];
        }];
    }];
}
#pragma mark --
#pragma mark -- 微博登录
- (IBAction)wbLoginClicked:(id)sender {
    WBAuthorizeRequest *  request = [WBAuthorizeRequest request];
    request.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"bangbang",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    //发送微博授权请求
    //响应会在appdelegate中获取，然后发通知到本控制器
    [WeiboSDK sendRequest:request];
}
-(void)wbDidRecvResponse:(NSNotification*)noti{
    WBAuthorizeResponse *response = noti.object;
    NSString *accessTokenWeiBo = response.accessToken;
    NSDate *expirationDate = response.expirationDate;
    NSTimeInterval interval = [expirationDate timeIntervalSinceNow];
    long intervalLong = interval;
    NSString *expiresWeiBo = [NSString stringWithFormat:@"%ld",intervalLong];
    NSString *currentUserId = response.userID;
    //获取微信用户信息
    [self.navigationController.view showLoadingTips:@""];
    [WBHttpRequest requestForUserProfile:currentUserId withAccessToken:accessTokenWeiBo andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest,id result,NSError *error){
        if (error) {
            [self.navigationController.view dismissTips];
            [self.navigationController.view showMessageTips:@"微博获取用户信息失败！"];
            return ;
        }
        WeiboUser *user = (WeiboUser *)result;
        //获取accessToken
        [IdentityHttp getAccessTokenhandler:^(id data, MError *error) {
            if(error) {
                [self.navigationController dismissTips];
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSString *accessToken = data[@"access_token"];
            _identityManager.identity.accessToken = accessToken;
            [_identityManager saveAuthorizeData];
            //登录
            [IdentityHttp socialLogin:user.userID unionId:@"" media_type:3 token:accessTokenWeiBo expires_in:expiresWeiBo client_type:@"ios" name:user.name avatar_url:user.avatarLargeUrl handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController.view dismissTips];
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                User *user = [User new];
                [user mj_setKeyValues:data];
                [_userManager loadUserWithGuid:user.user_guid];
                //获取融云token
                //把账号密码写入到输入框中 #BANG-527
//                _accountField.text = @(user.user_no).stringValue;
//                _passwordField.text = @"59bang.COM";
                [UserHttp getRYToken:user.user_no handler:^(id data, MError *error) {
                    [self.navigationController dismissTips];
                    if(error) {
                        [self.navigationController.view showFailureTips:error.statsMsg];
                        return ;
                    }
                    user.RYToken = data;
                    user.currCompany = [Company new];
                    [_userManager updateUser:user];
                    _identityManager.identity.user_guid = user.user_guid;
                    [_identityManager saveAuthorizeData];
                    //发通知 登录成功
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginDidFinish" object:nil];
                }];
            }];
        }];
    }];
}
#pragma mark --
#pragma mark -- 微信登陆
- (IBAction)wxLoginClicked:(id)sender {
    [self.view endEditing:YES];
    //阻止网页微信登陆
//    if(![WXApi isWXAppInstalled]) {
//        [self.navigationController.view showMessageTips:@"请下载微信客户端"];
//        return;
//    }
    SendAuthReq *req = [[SendAuthReq alloc]init];
    req.scope = @"snsapi_base,snsapi_userinfo";
    req.state = @"bangbang";
    req.openID = @"wxbd349c9a6abf20f8";
    //发送授权请求到微信
    //会在appdelegate中得到响应，登陆成功后会有通知到本控制器
    [WXApi sendReq:req];
}
-(void)wxDidRecvResponse:(NSNotification*)noti {
    SendAuthResp *response = noti.object;
    if (response.errCode == 0) {
        NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",@"wxbd349c9a6abf20f8",@"30068a0f26955393f85428d97fece628",response.code];
        [self.navigationController.view showLoadingTips:@""];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSString *requestStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
        if(!data) {
            [self.navigationController.view dismissTips];
            [self.navigationController.view showFailureTips:@"微信授权失败"];
            return ;
        }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *accessTokenWeiXin = [dic objectForKey:@"access_token"];
        NSString *openIdWeiXin = [dic objectForKey:@"openid"];
        NSString *expiresWeixin = [dic objectForKey:@"expires_in"];
        if (accessTokenWeiXin&&openIdWeiXin) {
            //获取微信用户信息
            [self getWXUserInfo:accessTokenWeiXin openID:openIdWeiXin expiresWeixin:expiresWeixin];
        }else{
            [self.navigationController.view dismissTips];
            [self.navigationController.view showFailureTips:@"微信授权失败"];
        }
    } else {
        [self.navigationController.view showFailureTips:@"微信授权失败"];
    }
}
//获取微信用户信息
- (void)getWXUserInfo:(NSString*)accessToken openID:(NSString*)openIdWeiXin expiresWeixin:(NSString*)expiresWeixin {
    NSString *urlStr = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openIdWeiXin];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *requestStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *data = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    if(!data) {
        [self.navigationController.view dismissTips];
        [self.navigationController.view showMessageTips:@"获取微信用户信息失败"];
        return ;
    }
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *userName = [dic objectForKey:@"nickname"];
    NSString *userAvatar = [dic objectForKey:@"headimgurl"];
    NSString *unionId = [dic objectForKey:@"unionid"];
    if (userName && userAvatar) {
        //获取accessToken
        [IdentityHttp getAccessTokenhandler:^(id data, MError *error) {
            if(error) {
                [self.navigationController dismissTips];
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSString *accessToken = data[@"access_token"];
            _identityManager.identity.accessToken = accessToken;
            [_identityManager saveAuthorizeData];
            //登陆
            [IdentityHttp socialLogin:unionId unionId:@"" media_type:2 token:accessToken expires_in:expiresWeixin client_type:@"ios" name:userName avatar_url:userAvatar handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController dismissTips];
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                User *user = [User new];
                [user mj_setKeyValues:data];
                [_userManager loadUserWithGuid:user.user_guid];
                //获取融云token
                //把账号密码写入到输入框中 #BANG-527
//                _accountField.text = @(user.user_no).stringValue;
//                _passwordField.text = @"59bang.COM";
                [UserHttp getRYToken:user.user_no handler:^(id data, MError *error) {
                    [self.navigationController dismissTips];
                    if(error) {
                        [self.navigationController.view showFailureTips:error.statsMsg];
                        return ;
                    }
                    user.RYToken = data;
                    [_userManager updateUser:user];
                    _identityManager.identity.user_guid = user.user_guid;
                    [_identityManager saveAuthorizeData];
                    //发通知 登录成功
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginDidFinish" object:nil];
                }];
            }];
        }];
    } else {
        [self.navigationController.view dismissTips];
        [self.navigationController.view showMessageTips:@"获取微信用户信息失败"];
    }
}
#pragma mark --
#pragma mark -- QQ登陆
- (IBAction)qqLoginClicked:(id)sender {
    [self.view endEditing:YES];
    //获取QQ用户信息
    NSArray* permissions =  [NSArray arrayWithObjects:@"get_user_info",@"get_simple_userinfo", nil];
    [_tencentOAuth authorize:permissions inSafari:NO];
}
- (void)tencentDidNotLogin:(BOOL)cancelled {}
- (void)tencentDidNotNetWork {}
- (void)tencentDidLogin
{
    //获取qq信息
    [_tencentOAuth getUserInfo];
}
//qq信息获取响应
-(void)getUserInfoResponse:(APIResponse *)response
{
    //获取失败
    if(![NSString isBlank:response.errorMsg]) {
        [self.navigationController.view showFailureTips:response.errorMsg];
        return;
    }
    NSString *avatar = [response.jsonResponse objectForKey:@"figureurl_qq_1"];
    NSString *name = [response.jsonResponse objectForKey:@"nickname"];
    long exptime = [[_tencentOAuth expirationDate] timeIntervalSinceDate:[NSDate date]];
    //登录
    [self.navigationController.view showLoadingTips:@""];
    [IdentityHttp getAccessTokenhandler:^(id data, MError *error) {
        if(error) {
            [self.navigationController dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        //#148
        NSString *accessToken = data[@"access_token"] ? : @"";
        _identityManager.identity.accessToken = accessToken;
        [_identityManager saveAuthorizeData];
        //用accessToken去获取qq的uuid
        [IdentityHttp getQqUuidWithToken:[_tencentOAuth accessToken] handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view dismissTips];
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSString *uuid = data;
            [IdentityHttp socialLogin:[_tencentOAuth openId] unionId:uuid media_type:1 token:[_tencentOAuth accessToken] expires_in:[NSString stringWithFormat:@"%ld",exptime] client_type:@"ios" name:name avatar_url:avatar handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController.view dismissTips];
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                User *user = [User new];
                [user mj_setKeyValues:data];
                [_userManager loadUserWithGuid:user.user_guid];
                //获取融云token
                //把账号密码写入到输入框中 #BANG-527
                //            _accountField.text = @(user.user_no).stringValue;
                //            _passwordField.text = @"59bang.COM";
                [UserHttp getRYToken:user.user_no handler:^(id data, MError *error) {
                    [self.navigationController dismissTips];
                    if(error) {
                        [self.navigationController.view showFailureTips:error.statsMsg];
                        return ;
                    }
                    user.RYToken = data;
                    [_userManager updateUser:user];
                    _identityManager.identity.user_guid = user.user_guid;
                    [_identityManager saveAuthorizeData];
                    //发通知 登录成功
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginDidFinish" object:nil];
                }];
            }];
        }];
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
