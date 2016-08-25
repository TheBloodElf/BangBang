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
@property (weak, nonatomic) IBOutlet UIButton *okBtn;//提交按钮
@end

@implementation UserLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置占位文字的颜色为红色(注意下面的'self'代表你要修改占位文字的UITextField控件)
    [self.accountField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
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
    //使用ARC来限制提交按钮是否能被点击
    RAC(self.okBtn, enabled) = [RACSignal combineLatest:@[self.accountField.rac_textSignal,self.passwordField.rac_textSignal] reduce:^(NSString *account,NSString *password){
        if([NSString isBlank:account])
            return @(NO);
        if([NSString isBlank:password])
            return @(NO);
        return @(YES);
    }];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
//账号密码登录
- (IBAction)palinLoginClicked:(id)sender {
    [self.view endEditing:YES];
    //获取token
    [self.navigationController showLoadingTips:@""];
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
        [IdentityHttp loginWithEmail:self.accountField.text password:self.passwordField.text handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController dismissTips];
                _identityManager.identity.user_guid = @"";
                [_identityManager saveAuthorizeData];
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            User *user = [[User alloc] initWithJSONDictionary:data];
            [_userManager loadUserWithGuid:user.user_guid];
            _identityManager.identity.user_guid = user.user_guid;
            [_identityManager saveAuthorizeData];
            [self comconRequestHttp:user];
        }];
    }];
}
//微信登录
- (IBAction)wxLoginClicked:(id)sender {
    [self.view endEditing:YES];
    SendAuthReq *req = [[SendAuthReq alloc]init];
    req.scope = @"snsapi_base,snsapi_userinfo";
    req.state = @"bangbang";
    req.openID = @"wxbd349c9a6abf20f8";
    [WXApi sendAuthReq:req viewController:self delegate:[WXApiManager sharedManager]];
}
//QQ登录
- (IBAction)qqLoginClicked:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController.view showLoadingTips:@""];
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
                        [UserHttp socialLogin:unionId media_type:2 token:accessToken expires_in:expiresWeixin client_type:@"ios" name:userName avatar_url:userAvatar handler:^(id data, MError *error) {
                            if(error) {
                                [self.navigationController dismissTips];
                                _identityManager.identity.user_guid = @"";
                                [_identityManager saveAuthorizeData];
                                [self.navigationController.view showFailureTips:error.statsMsg];
                                return ;
                            }
                            User *user = [[User alloc] initWithJSONDictionary:data];
                            [_userManager loadUserWithGuid:user.user_guid];
                            _identityManager.identity.user_guid = user.user_guid;
                            [_identityManager saveAuthorizeData];
                            [self comconRequestHttp:user];
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
    [_tencentOAuth getUserInfo];
}
-(void)getUserInfoResponse:(APIResponse *)response
{
    NSString *avatar = [response.jsonResponse objectForKey:@"figureurl_qq_1"];
    NSString *name = [response.jsonResponse objectForKey:@"nickname"];
    long exptime = [[_tencentOAuth expirationDate] timeIntervalSinceDate:[NSDate date]];
    //    登录
    [self.navigationController.view showLoadingTips:@""];
    [UserHttp socialLogin:[_tencentOAuth openId] media_type:1 token:[_tencentOAuth accessToken] expires_in:[NSString stringWithFormat:@"%ld",exptime] client_type:@"ios" name:name avatar_url:avatar handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        User *user = [[User alloc] initWithJSONDictionary:data];
        [_userManager loadUserWithGuid:user.user_guid];
        _identityManager.identity.user_guid = user.user_guid;
        [_identityManager saveAuthorizeData];
        [self comconRequestHttp:user];
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
            [self.navigationController showLoadingTips:@""];
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
                [UserHttp socialLogin:user.userID media_type:3 token:accessTokenWeiBo expires_in:expiresWeiBo client_type:@"ios" name:user.name avatar_url:user.avatarLargeUrl handler:^(id data, MError *error) {
                    if(error) {
                        [self.navigationController.view dismissTips];
                        [self.navigationController.view showFailureTips:error.statsMsg];
                        return ;
                    }
                    User *user = [[User alloc] initWithJSONDictionary:data];
                    [_userManager loadUserWithGuid:user.user_guid];
                    _identityManager.identity.user_guid = user.user_guid;
                    [_identityManager saveAuthorizeData];
                    [self comconRequestHttp:user];
                }];
            }];
        }
    }];
}
//共同的请求部分
- (void)comconRequestHttp:(User*)user {
    //获取所有圈子 所有状态员工
    [UserHttp getCompanysUserGuid:user.user_guid handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController dismissTips];
            _identityManager.identity.user_guid = @"";
            [_identityManager saveAuthorizeData];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *companys = [@[] mutableCopy];
        for (NSDictionary *tempDic in data) {
            Company *company = [[Company alloc] initWithJSONDictionary:tempDic];
            [companys addObject:company];
        }
        [_userManager updateCompanyArr:companys];
        if(companys.count != 0) {
            user.currCompany = [companys[0] deepCopy];
        }
        [_userManager updateUser:user];
        //获取所有圈子的员工信息
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
                Employee *employee = [[Employee alloc] initWithJSONDictionary:dic];
                [array addObject:employee];
            }
            [UserHttp getEmployeeCompnyNo:0 status:0 userGuid:user.user_guid handler:^(id data, MError *error) {
                if(error) {
                    [self.navigationController dismissTips];
                    _identityManager.identity.user_guid = @"";
                    [_identityManager saveAuthorizeData];
                    [self.navigationController.view showFailureTips:@"登陆失败，请重试"];
                    return ;
                }
                for (NSDictionary *dic in data[@"list"]) {
                    Employee *employee = [[Employee alloc] initWithJSONDictionary:dic];
                    [array addObject:employee];
                }
                [_userManager updateEmployee:array companyNo:0];
                //获取融云token
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
