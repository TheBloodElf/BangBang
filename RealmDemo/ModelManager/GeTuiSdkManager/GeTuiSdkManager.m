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
    if(![dict.allKeys containsObject:@"from_user_no"])
        [dict setObject:@(0) forKey:@"from_user_no"];
    if(![dict.allKeys containsObject:@"to_user_no"])
        [dict setObject:@(0) forKey:@"to_user_no"];
    if(![dict.allKeys containsObject:@"unread"])
        [dict setObject:@(1) forKey:@"unread"];
    PushMessage *message = [[PushMessage alloc] initWithJSONDictionary:dict];
    //如果程序处于前台，已读
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        message.unread = NO;
    } else {
        message.unread = YES;
    }
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
    message.addTime = [NSDate date];
    message.from_user_no =  [[dict objectForKey:@"from"] intValue];
    message.to_user_no = [[dict objectForKey:@"to"] intValue];
    
    //如果是投票和公告 因为没有存到本地数据库，所以不操作
    if ([message.type isEqualToString:@"VOTE"] || [message.type isEqualToString:@"NOTICE"]) {
        message.to_user_no = _userManager.user.user_no;
    }
    //如果是会议 因为没有存到本地数据库 所以不操作
    if ([message.action isEqualToString:@"MEETING_RECEIVE"]) {
        
    } else if ([message.action isEqualToString:@"VOTE_ADD"]&& message.from_user_no == _userManager.user.user_no){
        
    }
    //如果是分享过来的日程，存入数据库
    if ([message.type isEqualToString:@"CALENDAR"] && ![NSString isBlank:message.entity]) {
        NSData *calendarData = [[dict objectForKey:@"entity"] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
        Calendar *sharedCalendar = [[Calendar alloc] initWithJSONDictionary:calendarDic];
        if (sharedCalendar) {
            [_userManager addCalendar:sharedCalendar];
        }
    }
    //圈子操作
    if ([message.type isEqualToString:@"COMPANY"]) {
        //同意加入圈子
        if ([message.action rangeOfString:@"COMPANY_ALLOW_JOIN"].location != NSNotFound) {
            //改变自己在里面的状态 更新圈子数组
            Employee *employee = [[_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no] deepCopy];
            employee.status = 1;
            [_userManager updateEmployee:employee];
            for (Company *company in [_userManager getCompanyArr]) {
                if(company.company_no == message.company_no) {
                    [_userManager updateCompany:company];
                    break;
                }
            }
        } else if ([message.action rangeOfString:@"COMPANY_ALLOW_LEAVE"].location != NSNotFound){//同意退出圈子
            //改变自己在里面的状态 更新圈子数组
            Employee *employee = [[_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no] deepCopy];
            employee.status = 2;
            [_userManager updateEmployee:employee];
            for (Company *company in [_userManager getCompanyArr]) {
                if(company.company_no == message.company_no) {
                    [_userManager updateCompany:company];
                    break;
                }
            }
        }  else if ([message.action rangeOfString:@"COMPANY_REFUSE_JOIN"].location != NSNotFound) {//拒绝加入圈子
            Employee *employee = [[_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no] deepCopy];
            employee.status = 3;
            [_userManager updateEmployee:employee];
        } else if ([message.action rangeOfString:@"COMPANY_TRANSFER"].location != NSNotFound) {//转让圈子 修改圈子的创建者为自己
            NSArray *array = [_userManager getCompanyArr];
            Employee * employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no];
            for (Company *company in array) {
                if(company.company_no == message.company_no) {
                    Company *temp = [company deepCopy];
                    temp.admin_user_guid = employee.user_guid;
                    [_userManager updateCompany:temp];
                    break;
                }
            }
            
        } else if ([message.action rangeOfString:@"COMPANY_REFUSE_LEAVE"].location != NSNotFound) {//拒绝离开圈子 改变员工状态
            Employee *employee = [[_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:message.company_no] deepCopy];
            employee.status = 1;
            [_userManager updateEmployee:employee];
            
        } else {//某某某请求加入/退出圈子  获取所有状态的员工 更新
            
            for (Company *company in [_userManager getCompanyArr]) {
                if(company.company_no == message.company_no) {
                    User *user = [_userManager.user deepCopy];
                    user.currCompany = [company deepCopy];
                    [_userManager updateUser:user];
                    break;
                }
            }
            
            [UserHttp getEmployeeCompnyNo:message.company_no status:0 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                if(error) {
                    return ;
                }
                NSMutableArray *array = [@[] mutableCopy];
                for (NSDictionary *dic in data[@"list"]) {
                    Employee *employee = [[Employee alloc] initWithJSONDictionary:dic];
                    [array addObject:employee];
                }
                [UserHttp getEmployeeCompnyNo:message.company_no status:4 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                    if(error) {
                        return ;
                    }
                    for (NSDictionary *dic in data[@"list"]) {
                        Employee *employee = [[Employee alloc] initWithJSONDictionary:dic];
                        [array addObject:employee];
                    }
                    //存入本地数据库
                    for (Employee *employee in array) {
                        [_userManager updateEmployee:employee];
                    }
                }];
            }];
        }
    }
    if ([message.action rangeOfString:@"CHANGE_PASSWORD"].location != NSNotFound) { //修改密码
        [[IdentityManager manager] showLogin];
    }
    if ([message.action isEqualToString:@"MEETING_RECEIVE"]){//接受会议
        NSData *calendarData = [[dict objectForKey:@"entity"] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
        Calendar *meetingCalendar = [[Calendar alloc] initWithJSONDictionary:calendarDic];
        if (meetingCalendar) {
            [_userManager addCalendar:meetingCalendar];
        }
    }
    [_userManager addPushMessage:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecivePushMessage" object:message];
}
@end
