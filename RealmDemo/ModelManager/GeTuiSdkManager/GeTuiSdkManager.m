//
//  GeTuiSdkManager.m
//  RealmDemo
//
//  Created by Mac on 16/7/24.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "GeTuiSdkManager.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "IdentityManager.h"

@interface GeTuiSdkManager () <GeTuiSdkDelegate>{
    UserManager *_userManager;
}

@end

@implementation GeTuiSdkManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userManager = [UserManager manager];
    }
    return self;
}

+ (instancetype)manager {
    static GeTuiSdkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GeTuiSdkManager alloc] init];
    });
    return manager;
}

- (void)startGeTuiSdk {
    [GeTuiSdk startSdkWithAppId:kAppId appKey:kAppKey appSecret:kAppSecret delegate:self];
}
- (void)stopGeTuiSdk {
    [GeTuiSdk destroy];
}
- (void)registerDeviceToken:(NSString*)deviceToken {
    [GeTuiSdk registerDeviceToken:deviceToken];
}
#pragma mark -- GeTuiSdkDelegate
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    [GeTuiSdk bindAlias:@(_userManager.user.user_no).stringValue];
    [UserHttp setupAPNSDevice:clientId userNo:_userManager.user.user_no handler:^(id data, MError *error) {}];
}
-(void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    //在这里处理个推推送
    NSData* payload = [GeTuiSdk retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length
                                            encoding:NSUTF8StringEncoding];
    }
    NSData *jsonData = [payloadMsg dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    PushMessage *message = [PushMessage new];
    [message mj_setKeyValues:dict];
    message.addTime = [NSDate date];
    message.from_user_no =  [[dict objectForKey:@"from"] intValue];
    message.to_user_no = [[dict objectForKey:@"to"] intValue];
    if ([message.type isEqualToString:@"VOTE"] || [message.type isEqualToString:@"NOTICE"]) {
        message.to_user_no = _userManager.user.user_no;
    }
    //如果程序处于前台，就未读状态
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        message.unread = NO;
    } else {
        message.unread = YES;
    }
    //接受会议
    if ([message.action isEqualToString:@"MEETING_RECEIVE"]) {
        
    } else if ([message.action isEqualToString:@"VOTE_ADD"]&& message.from_user_no == _userManager.user.user_no){
        
    } else {
        [_userManager addPushMessage:message];
        if (message.unread == YES) {
            //未读的 不是接受会议推送的和自己发起的投票推送 播放声音
            IdentityManager *identityManager = [IdentityManager manager];
            if (identityManager.identity.canPlayVoice != 1) {
                AudioServicesPlaySystemSound(1007); //系统的通知声音
            }
            if (identityManager.identity.canPlayShake != 1) {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);//震动
            }
        }
    }
    //如果是分享过来的日程，存入数据库
    if ([message.type isEqualToString:@"CALENDAR"] && ![NSString isBlank:message.entity]) {
        NSData *calendarData = [[dict objectForKey:@"entity"] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
        Calendar *sharedCalendar = [Calendar new];
        [sharedCalendar mj_setKeyValues:calendarDic];
        if (sharedCalendar) {
            [_userManager addCalendar:sharedCalendar];
        }
    }
    //同意加入圈子
    if ([message.action rangeOfString:@"COMPANY_ALLOW_JOIN"].location != NSNotFound) {
        NSData *calendarData = [[dict objectForKey:@"entity"] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *companyDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
        Company *company = [Company new];
        [company mj_setKeyValues:companyDic];
        [_userManager addCompany:company];
    }else if([message.action rangeOfString:@"COMPANY_ALLOW_LEAVE"].location != NSNotFound){//同意退出圈子
        int companyNo = message.company_no;
        NSArray *array = [_userManager getCompanyArr];
        for (Company *company in array) {
            if(company.company_no == companyNo) {
                [_userManager deleteCompany:company];
                break;
            }
        }
    }  else if ([message.action rangeOfString:@"COMPANY_ALLOW_LEAVE"].location != NSNotFound) { //修改密码
        [[IdentityManager manager] showLogin];
    } else if ([message.action isEqualToString:@"MEETING_RECEIVE"]){//接受会议
        NSData *calendarData = [[dict objectForKey:@"entity"] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
        Calendar *meetingCalendar = [Calendar new];
        [meetingCalendar mj_setKeyValues:calendarDic];
        if (meetingCalendar) {
            [_userManager addCalendar:meetingCalendar];
        }
    }
    //任务状态有变化 需要刷新任务列表等地方
    if ([message.type isEqualToString:@"TASK_COMMENT_STATUS"]) {
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecivePushMessage" object:message];
}
@end
