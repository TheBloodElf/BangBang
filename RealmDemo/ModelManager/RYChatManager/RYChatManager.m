//
//  RYChatManager.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/18.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RYChatManager.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "IdentityManager.h"

@implementation RYChatManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置信息提供者
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
        [[RCIM sharedRCIM] setGroupInfoDataSource:self];
    }
    return self;
}

+ (RYChatManager*)shareInstance
{
    static RYChatManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        
    });
    return instance;
}
- (void)syncRYGroup {
    //同步群组
    [UserHttp syncRYGroup:[UserManager manager].user.user_no handler:^(id data, MError *error) {
        
    }];
}
- (void)registerRYChat {
    // 快速集成第一步，初始化融云SDK
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    //设置会话列表头像和会话界面头像
    [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(43, 43);
    //设置用户信息源和群组信息源
    [RCIM sharedRCIM].userInfoDataSource = self;
    [RCIM sharedRCIM].groupInfoDataSource = self;
    [RCIM sharedRCIM].connectionStatusDelegate = self;
}
#pragma mark - GroupInfoFetcherDelegate
- (void)getGroupInfoWithGroupId:(NSString*)groupId completion:(void (^)(RCGroup*))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<Company*> *companyArr = [[UserManager manager] getCompanyArr];
        for (Company *company in companyArr) {
            if(company.company_no == [groupId intValue]) {
                RCGroup * group = [[RCGroup alloc]init];
                group.groupId = groupId;
                group.groupName = company.company_name;
                group.portraitUri = company.logo;
                completion(group);
            }
        }
    });
}

#pragma mark - RCIMUserInfoFetcherDelegagte
- (void)getUserInfoWithUserId:(NSString*)userId completion:(void (^)(RCUserInfo*))completion
{
     dispatch_async(dispatch_get_main_queue(), ^{
        UserManager *manager = [UserManager manager];
        Employee * it = [manager getEmployeeWithNo:[userId intValue]];
        RCUserInfo * user = [[RCUserInfo alloc] init];
        user.userId = userId;
        user.name = it.user_real_name;
        user.portraitUri = it.avatar;
        completion(user);
     });
}
#pragma mark - 融云连接状态监听
-(void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
    NSString *result = nil;
    switch (status) {
        case -1:result = @"未知状态。";break;
        case 0:result = @"连接成功。";break;
        case 1:result = @"网络连接不可用。";break;
        case 2: result = @"设备处于飞行模式。";break;
        case 3:result = @"设备处于2G低网速下。";break;
        case 4:result = @"设备处于3G,4G网速下。";break;
        case 5: result = @"设备切换到WIFI网络下。";break;
        case 6:result = @"设备在其它设备登陆。";break;
        case 12:result = @"注销";break;
        case 31004:result = @"Token无效，可能是token错误，token过期或者后台刷新了密钥等原因。";break;
        case 31011:result = @"服务器断开连接。";break;
        default:result = @"其他状态。";break;
    }
    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
        [[IdentityManager manager] showLogin];
    }
}
@end
