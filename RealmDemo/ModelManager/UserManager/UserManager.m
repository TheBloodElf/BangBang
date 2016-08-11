//
//  UserManager.m
//  RealmDemo
//
//  Created by haigui on 16/7/2.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "UserManager.h"
#import "UserInfo.h"

//本地推送需要最近几天的内容
#define LocNotifotionDays 4

@interface UserManager () {
    RLMRealm *_rlmRealm;
}

@end

@implementation UserManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)manager {
    static UserManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserManager alloc] init];
    });
    return manager;
}
#pragma makr -- 本地推送
- (void)addSiginRuleNotfition {
    //清除本地签到规则推送
    NSArray<UILocalNotification *> *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *cation in scheduledLocalNotifications) {
        if([cation.alertBody containsString:@"上下班提醒"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:cation];
        }
    }
    //获取签到规则
    NSArray<SiginRuleSet*> *siginModelArr = [self getSiginRule:_user.currCompany.company_no];
    if(siginModelArr.count == 0) return;
    dispatch_sync(dispatch_queue_create(0, 0), ^{
        //只取第一个 因为目前一个圈子只有一个
        SiginRuleSet *model = siginModelArr[0];
        if(model.is_alert == 0) return;
        NSLog(@"有上下班提醒通知");
        //得到一天开始后上班多少时间提醒
        NSUInteger begin = (model.start_work_time / 1000 - model.start_work_time_alert * 60) % (24 * 60 * 60);
        //得到一天开始后下班多少时间提醒
        NSUInteger end = (model.end_work_time / 1000 + model.end_work_time_alert * 60) % (24 * 60 * 60);
        //得到今天凌晨的时间戳（小技巧，有其他方法的）
        NSUInteger time = [[NSDate date] timeIntervalSince1970];
        NSUInteger today = (time / (24 * 60 * 60)) * (24 * 60 * 60);
        //得到需要提醒的星期数组
        NSArray *weekArr = [model.work_day componentsSeparatedByString:@","];
        //循环着创建最近5天的本地通知
        for (NSUInteger index = 0; index < LocNotifotionDays; index ++) {
            //今天上班时间
            NSDate *currUpTime = [NSDate dateWithTimeIntervalSince1970:today + index * 24 * 60 * 60 + begin];
            //如果设置了今天提醒
            if([weekArr containsObject:[NSString stringWithFormat:@"%ld",currUpTime.weekday]]) {
                //如果小于现在 去掉
                if([currUpTime timeIntervalSinceDate:[NSDate date]] < 0) {}
                else [self addUpDownWorkLocNoti:model date:currUpTime type:0];
            }
            //今天下班时间
            NSDate *currEndTime = [NSDate dateWithTimeIntervalSince1970:today + index * 24 * 60 * 60 + end];
            //如果设置了今天提醒
            if([weekArr containsObject:[NSString stringWithFormat:@"%ld",currEndTime.weekday]]) {
                //如果小于现在 去掉
                if([currEndTime timeIntervalSinceDate:[NSDate date]] < 0) {}
                else [self addUpDownWorkLocNoti:model date:currEndTime type:1];
            }
        }
    });
}
//添加上下班时间提醒 type:0（上班） 1（下班） date:提醒的时间
- (void)addUpDownWorkLocNoti:(SiginRuleSet *)siginRule date:(NSDate*)date type:(NSInteger)type{
    // 初始化本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
    notification.fireDate = date;
    // 设置重复间隔
    notification.repeatInterval = 0;
    // 设置提醒的文字内容
    NSString *alertBody = nil;
    if(type == 0) {
        alertBody = @"上下班提醒：上班了";
        if(siginRule.end_work_time_alert != 0)
            alertBody = [NSString stringWithFormat:@"上下班提醒：还有 %@分钟上班了",@(siginRule.start_work_time_alert)];
    } else {
        alertBody = @"上下班提醒：下班了";
        if(siginRule.end_work_time_alert != 0)
            alertBody = [NSString stringWithFormat:@"上下班提醒：下班%@分钟了",@(siginRule.end_work_time_alert)];
    }
    notification.alertBody  = alertBody;
    notification.alertAction = NSLocalizedString(@"帮帮管理助手", nil);
    // 通知提示音 使用默认的
    notification.soundName= @"notification_ring.mp3";
    // 设置应用程序右上角的提醒个数 上下班不需要加数字
    notification.applicationIconBadgeNumber++;
    // 设定通知的userInfo，用来标识该通知
    NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
    [aUserInfo setObject:@"WORKTIP" forKey:@"type"];
    [aUserInfo setObject:alertBody forKey:@"content"];
    [aUserInfo setObject:[NSString stringWithFormat:@"%@",@([date timeIntervalSince1970] * 1000)] forKey:@"time"];
    [aUserInfo setObject:@"GENERAL" forKey:@"action"];
    [aUserInfo setObject:@([NSDate date].timeIntervalSince1970 * 1000).stringValue forKey:@"target_id"];
    [aUserInfo setObject:@(_user.user_no) forKey:@"from_user_no"];
    [aUserInfo setObject:@(_user.user_no) forKey:@"to_user_no"];
    [aUserInfo setObject:@(YES) forKey:@"unread"];
    [aUserInfo setObject:@(_user.currCompany.company_no) forKey:@"company_no"];
    notification.userInfo = aUserInfo;
    // 将通知添加到系统中
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
- (void)addCalendarNotfition {
    //清除本地日程推送
    NSArray<UILocalNotification *> *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *cation in scheduledLocalNotifications) {
        if([cation.alertBody containsString:@"事务提醒"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:cation];
        }
    }
    //获取本地5天的日程
    NSDate *date = [NSDate date];
    for (int index = 0; index < LocNotifotionDays; index ++) {
        NSDate *currDate = [date dateByAddingTimeInterval:index * 24 * 60 * 60];
        NSMutableArray<Calendar*> *calendarArr =  [self getCalendarArrWithDate:currDate];
         dispatch_sync(dispatch_queue_create(0, 0), ^{
                //一天一天的加本地推送
                for (Calendar *calendar in calendarArr) {
                    if(calendar.status == 2) continue;//如果已经完成就不添加本地推送
                    if(calendar.repeat_type == 0) {//如果是不重复的日程
                        NSDate *alertBeforeDate = [NSDate dateWithTimeIntervalSince1970:calendar.begindate_utc / 1000 - calendar.alert_minutes_before * 60];
                        if(alertBeforeDate.timeIntervalSince1970 < date.timeIntervalSince1970) { } else {
                            //添加到本地推送
                            [self addCalendarAlertToLocNoti:calendar date:alertBeforeDate];
                        }
                        
                        NSDate *alertAfterDate = [NSDate dateWithTimeIntervalSince1970:calendar.enddate_utc / 1000 + calendar.alert_minutes_after * 60];
                        if(alertAfterDate.timeIntervalSince1970 < date.timeIntervalSince1970) { } else {
                            //添加到本地推送
                            [self addCalendarAlertToLocNoti:calendar date:alertAfterDate];
                        }
                    } else {//如果是重复的日程
                        if(calendar.rrule.length > 0 && calendar.r_begin_date_utc>0 && calendar.r_end_date_utc > 0) {
                            Scheduler * scheduler = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:calendar.begindate_utc/1000] andRule:calendar.rrule];
                            //得到所有的时间
                            NSArray * occurences = [scheduler occurencesBetween:currDate.firstTime andDate:currDate.lastTime];
                            //遍历所有的时间
                            for (NSDate *dddd in occurences) {
                                if([dddd timeIntervalSince1970] < calendar.r_begin_date_utc/1000) {
                                    continue;
                                } else if ([calendar haveDeleteDate:currDate]) {
                                    continue;
                                } else if ([calendar haveFinishDate:currDate]) {
                                    continue;
                                } else if(dddd.timeIntervalSince1970 < date.timeIntervalSince1970) {
                                } else {
                                    [self addCalendarAlertToLocNoti:calendar date:dddd];
                                }
                            }
                        }
                    }
                }
         });
    }
}
-(void)addCalendarAlertToLocNoti:(Calendar*)calendar date:(NSDate*)date{
    // 初始化本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
    notification.fireDate = date;
    // 设置重复间隔
    notification.repeatInterval = 0;
    // 设置提醒的文字内容
    notification.alertBody   = [NSString stringWithFormat:@"事务提醒: %@",calendar.event_name];
    notification.alertAction = NSLocalizedString(@"帮帮管理助手", nil);
    notification.soundName = @"notification_ring.mp3";
    // 设置应用程序右上角的提醒个数
    notification.applicationIconBadgeNumber++;
    // 设定通知的userInfo，用来标识该通知
    NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
    [aUserInfo setObject:@(calendar.id).stringValue forKey:@"target_id"];
    [aUserInfo setObject:@"CALENDARTIP" forKey:@"type"];
    [aUserInfo setObject:[NSString stringWithFormat:@"事务提醒: %@", calendar.event_name] forKey:@"content"];
    [aUserInfo setObject:[NSString stringWithFormat:@"%lld",calendar.begindate_utc] forKey:@"time"];
    [aUserInfo setObject:@"0" forKey:@"company_no"];
    [aUserInfo setObject:@(_user.user_no) forKey:@"from_user_no"];
    [aUserInfo setObject:@(_user.user_no) forKey:@"to_user_no"];
    [aUserInfo setObject:@(YES) forKey:@"unread"];
    [aUserInfo setObject:@"GENERAL" forKey:@"action"];
    [aUserInfo setObject:@(_user.currCompany.company_no) forKey:@"company_no"];
    notification.userInfo = aUserInfo;
    // 将通知添加到系统中
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
- (void)addTaskNotfition {
    //清除本地任务推送
    NSArray<UILocalNotification *> *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *cation in scheduledLocalNotifications) {
        if([cation.alertBody containsString:@"任务提醒"]) {
            [[UIApplication sharedApplication] cancelLocalNotification:cation];
        }
    }
    //添加5天内的任务推送
    NSArray<TaskModel*> *taskArr = [self getTaskArr:_user.currCompany.company_no];
    dispatch_sync(dispatch_queue_create(0, 0), ^{
        NSDate *currDate = [NSDate date];
        for (TaskModel *model in taskArr) {
            if(model.status == 0 || model.status == 1 || model.status == 7 || model.status == 8) continue;//去掉不提醒的
            if([NSString isBlank:model.alert_date_list]) continue;//去掉没有提醒时间的
            
            NSArray *alertStrArr = [model.alert_date_list componentsSeparatedByString:@","];
            for (NSString *str in alertStrArr) {
                NSDate *currAlertDate = [NSDate dateWithTimeIntervalSince1970:str.integerValue / 1000];
                if(currAlertDate.timeIntervalSince1970 > currDate.timeIntervalSince1970 && currAlertDate.timeIntervalSince1970 < [currDate dateByAddingTimeInterval:LocNotifotionDays * 24 * 60 * 60].timeIntervalSince1970) {//得到在提醒天数之内的时间
                    [self addTaskAlertToLocNoti:model date:currAlertDate];
                }
            }
        }
    });
}
- (void)addTaskAlertToLocNoti:(TaskModel*)task date:(NSDate*)date
{
    // 初始化本地通知对象
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.timeZone = [NSTimeZone defaultTimeZone]; // 使用本地时区
    notification.fireDate = date;
    // 设置重复间隔
    notification.repeatInterval = 0;
    // 设置提醒的文字内容
    notification.alertBody   = [NSString stringWithFormat:@"任务提醒: %@还有", task.task_name];
    notification.alertAction = NSLocalizedString(@"帮帮管理助手", nil);
    // 通知提示音 使用默认的
    notification.soundName= @"notification_ring.mp3";
    // 设置应用程序右上角的提醒个数
    notification.applicationIconBadgeNumber++;
    // 设定通知的userInfo，用来标识该通知
    NSMutableDictionary *aUserInfo = [[NSMutableDictionary alloc] init];
    [aUserInfo setObject:@(task.id).stringValue forKey:@"target_id"];
    [aUserInfo setObject:@"TASKTIP" forKey:@"type"];
    [aUserInfo setObject:[NSString stringWithFormat:@"任务提醒: %@", task.task_name] forKey:@"content"];
    [aUserInfo setObject:[NSString stringWithFormat:@"%@",@([date timeIntervalSince1970] * 1000)] forKey:@"time"];
    [aUserInfo setObject:@(task.company_no) forKey:@"company_no"];
    [aUserInfo setObject:@(_user.user_no) forKey:@"from_user_no"];
    [aUserInfo setObject:@(_user.user_no) forKey:@"to_user_no"];
    [aUserInfo setObject:@(YES) forKey:@"unread"];
    [aUserInfo setObject:@"GENERAL" forKey:@"action"];
    notification.userInfo = aUserInfo;
    // 将通知添加到系统中
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
#pragma mark -- User
//更新用户数据
- (void)updateUser:(User*)user {
    [_rlmRealm beginWriteTransaction];
    [User createOrUpdateInRealm:_rlmRealm withValue:user];
    self.user = user;
    [_rlmRealm commitWriteTransaction];
    //把用户数据放到应用组间共享数据
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.lottak.bangbang"];
    UserInfo *userInfo = [UserInfo new];
    userInfo.user_guid = _user.user_guid;
    [NSKeyedArchiver setClassName:@"UserInfo" forClass:[UserInfo class]];
    [sharedDefaults setValue:[NSKeyedArchiver archivedDataWithRootObject:userInfo] forKey:@"GroupUserInfo"];
    [sharedDefaults synchronize];
}
//通过用户guid加载用户
- (void)loadUserWithGuid:(NSString*)userGuid {
    //得到用户对应的数据库路径
    NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *pathUrl = pathArr[0];
    pathUrl = [pathUrl stringByAppendingPathComponent:userGuid];
    //创建数据库
    _rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:pathUrl]];
    //得到/创建用户数据
    RLMResults *users = [User allObjectsInRealm:_rlmRealm];
    if(users.count) {
        self.user = [users objectAtIndex:0];
    } else {
        self.user = [User new];
    }
}
//创建用户的数据库观察者
- (RBQFetchedResultsController*)createUserFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user_guid = %@",_user.user_guid];
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"User" inRealm:_rlmRealm predicate:predicate];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
//获取所有员工
- (NSMutableArray<Employee*>*)getEmployeeArr {
    [_rlmRealm beginWriteTransaction];
    RLMResults *results = [Employee objectsInRealm:_rlmRealm withPredicate:nil];
    [_rlmRealm commitWriteTransaction];
    NSMutableArray *array = [@[] mutableCopy];
    for (int index = 0; index < results.count; index ++) {
        [array addObject:[results objectAtIndex:index]];
    }
    return array;
}
//根据Guid和圈子ID获取员工
- (Employee*)getEmployeeWithGuid:(NSString*)userGuid companyNo:(int)companyNo {
    [_rlmRealm beginWriteTransaction];
    NSPredicate *pred  = [NSPredicate predicateWithFormat:@"user_guid = %@ and company_no = %d",userGuid,companyNo];
    RLMResults *results = [Employee objectsInRealm:_rlmRealm withPredicate:pred];
    [_rlmRealm commitWriteTransaction];
    //如果有值就返回 没有就算了
    if(results.count)
        return [results objectAtIndex:0];
    return [Employee new];
}
#pragma mark -- Company
//更新某个圈子信息
- (void)updateCompany:(Company*)company {
    [_rlmRealm beginWriteTransaction];
    [Company createOrUpdateInRealm:_rlmRealm withValue:company];
    [_rlmRealm commitWriteTransaction];
}
//添加某个圈子
- (void)addCompany:(Company*)company {
    [_rlmRealm beginWriteTransaction];
    [Company createOrUpdateInRealm:_rlmRealm withValue:company];
    [_rlmRealm commitWriteTransaction];
}
//删除某个圈子
- (void)deleteCompany:(Company*)company {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm deleteObject:company];
    [_rlmRealm commitWriteTransaction];
}
//更新所有圈子数据
- (void)updateCompanyArr:(NSArray<Company*>*)companyArr {
    [_rlmRealm beginWriteTransaction];
    RLMResults *companys = [Company allObjectsInRealm:_rlmRealm];
    while (companys.count)
        [_rlmRealm deleteObject:companys.firstObject];
    for (Company *company in companyArr) {
        [Company createOrUpdateInRealm:_rlmRealm withValue:company];
    }
    [_rlmRealm commitWriteTransaction];
}
//获取圈子数组
- (NSMutableArray<Company*>*)getCompanyArr {
    NSMutableArray<Company*> *companyArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    RLMResults *companys = [Company allObjectsInRealm:_rlmRealm];
    for (int index = 0;index < companys.count;index ++) {
        Company *company = [companys objectAtIndex:index];
        [companyArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return companyArr;
}
//创建圈子的数据库观察者
- (RBQFetchedResultsController*)createCompanyFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Company" inRealm:_rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- Employee
//更新某个员工
- (void)updateEmployee:(Employee*)emplyee {
    [_rlmRealm beginWriteTransaction];
    [Employee createOrUpdateInRealm:_rlmRealm withValue:emplyee];
    [_rlmRealm commitWriteTransaction];
}
//根据圈子ID更新所有员工信息
- (void)updateEmployee:(NSMutableArray<Employee*>*)employeeArr companyNo:(int)companyNo{
    [_rlmRealm beginWriteTransaction];
    NSPredicate *pred = nil;
    //如果有圈子id就查询指定圈子员工 如果有状态就查询状态
    if(companyNo)
        pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
    RLMResults *results = [Employee objectsInRealm:_rlmRealm withPredicate:pred];
    while (results.count)
        [_rlmRealm deleteObject:results.firstObject];
    for (Employee * employee in employeeArr) {
        [Employee createOrUpdateInRealm:_rlmRealm withValue:employee];
    }
    [_rlmRealm commitWriteTransaction];
}
//根据圈子ID获取员工信息
- (NSMutableArray<Employee*>*)getEmployeeWithCompanyNo:(int)companyNo status:(int)status{
    NSMutableArray *array = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    NSPredicate *pred = nil;
    //如果有圈子id就查询指定圈子员工 如果有状态就查询状态 5查询在职 -1 查询所有
    if(companyNo) {
        if(status == -1) {
            pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
        } else if(status == 5) {
            pred = [NSPredicate predicateWithFormat:@"company_no = %d and (status = 1 or status = 4)",companyNo];
        } else {
            pred = [NSPredicate predicateWithFormat:@"company_no = %d and status = %d",companyNo,status];
        }
    } else {
        if(status == -1) {
            
        } else if(status == 5) {
            pred = [NSPredicate predicateWithFormat:@"status = 1 or status = 4"];
        } else {
            pred = [NSPredicate predicateWithFormat:@"status = %d",status];
        }
    }
    RLMResults *results = [Employee objectsInRealm:_rlmRealm withPredicate:pred];
    for (int index = 0;index < results.count;index ++) {
        Employee *employee = [results objectAtIndex:index];
        [array addObject:employee];
    }
    [_rlmRealm commitWriteTransaction];
    return array;
}
//根据圈子和状态创建数据库监听
- (RBQFetchedResultsController*)createEmployeesFetchedResultsControllerWithCompanyNo:(int)companyNo {
    RBQFetchedResultsController *fetchedResultsController = nil;
    NSPredicate *pred = nil;
    pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Employee" inRealm:_rlmRealm predicate:pred];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- PushMessage
//添加某个推送消息
- (void)addPushMessage:(PushMessage*)pushMessage {
    [_rlmRealm beginWriteTransaction];
    [PushMessage createOrUpdateInRealm:_rlmRealm withValue:pushMessage];
    [_rlmRealm commitWriteTransaction];
}
//修改某个推送消息
- (void)updatePushMessage:(PushMessage*)pushMessage {
    [_rlmRealm beginWriteTransaction];
    [PushMessage createOrUpdateInRealm:_rlmRealm withValue:pushMessage];
    [_rlmRealm commitWriteTransaction];
}
//删除某个推送消息
- (void)deletePushMessage:(PushMessage*)pushMessage {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm deleteObject:pushMessage];
    [_rlmRealm commitWriteTransaction];
}
//获取所有的推送消息
- (NSMutableArray<PushMessage*>*)getPushMessageArr {
    NSMutableArray<PushMessage*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [PushMessage allObjectsInRealm:_rlmRealm];
    for (int index = 0;index < pushMessages.count;index ++) {
        PushMessage *company = [pushMessages objectAtIndex:index];
        [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//创建消息数据监听
- (RBQFetchedResultsController*)createPushMessagesFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"PushMessage" inRealm:_rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- UserDiscuss
//添加通讯录中的讨论组
- (void)addUserDiscuss:(UserDiscuss*)userDiscuss {
    [_rlmRealm beginWriteTransaction];
    [UserDiscuss createOrUpdateInRealm:_rlmRealm withValue:userDiscuss];
    [_rlmRealm commitWriteTransaction];
}
//删除通讯录中的讨论组
- (void)deleteUserDiscuss:(UserDiscuss*)userDiscuss {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm deleteObject:userDiscuss];
    [_rlmRealm commitWriteTransaction];
}
//更新所有讨论组
- (void)updateUserDiscussArr:(NSMutableArray<UserDiscuss*>*)userDiscussArr {
    [_rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [UserDiscuss allObjectsInRealm:_rlmRealm];
    while (pushMessages.count)
        [_rlmRealm deleteObject:pushMessages.firstObject];
    for (UserDiscuss *userDiscuss in userDiscussArr) {
        [UserDiscuss createOrUpdateInRealm:_rlmRealm withValue:userDiscuss];
    }
    [_rlmRealm commitWriteTransaction];
}
//获取所有的讨论组
- (NSMutableArray<UserDiscuss*>*)getUserDiscussArr {
    NSMutableArray<UserDiscuss*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [UserDiscuss allObjectsInRealm:_rlmRealm];
    for (int index = 0;index < pushMessages.count;index ++) {
        UserDiscuss *company = [pushMessages objectAtIndex:index];
        [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//创建讨论组数据监听
- (RBQFetchedResultsController*)createUserDiscusFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"UserDiscuss" inRealm:_rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- Calendar
//添加日程
- (void)addCalendar:(Calendar*)calendar {
    [_rlmRealm beginWriteTransaction];
    [Calendar createOrUpdateInRealm:_rlmRealm withValue:calendar];
    [_rlmRealm commitWriteTransaction];
}
//更新日程
- (void)updateCalendar:(Calendar*)calendar {
    [_rlmRealm beginWriteTransaction];
    [Calendar createOrUpdateInRealm:_rlmRealm withValue:calendar];
    [_rlmRealm commitWriteTransaction];
}
//更新所有的日程
- (void)updateCalendars:(NSMutableArray<Calendar*>*)calendarArr {
    [_rlmRealm beginWriteTransaction];
    RLMResults *rLMResults = [Calendar allObjects];
    while (rLMResults.count) {
        [_rlmRealm deleteObject:[rLMResults objectAtIndex:0]];
    }
    for (Calendar *calendar in calendarArr) {
        [Calendar createOrUpdateInRealm:_rlmRealm withValue:calendar];
    }
    [_rlmRealm commitWriteTransaction];
}
//获取指定时间的日程 未删除的
- (NSMutableArray<Calendar*>*)getCalendarArrWithDate:(NSDate*)date {
    NSMutableArray<Calendar*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    int64_t dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    int64_t dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSString *resultStr = [NSString stringWithFormat:@"((enddate_utc >= %lld and begindate_utc <= %lld ) or (enddate_utc >= %lld and begindate_utc <= %lld ) or (enddate_utc <= %lld and begindate_utc >= %lld ) or (r_end_date_utc >= %lld and r_begin_date_utc <= %lld ) or (r_end_date_utc >= %lld and r_begin_date_utc <= %lld ) or (r_end_date_utc <= %lld and r_begin_date_utc >= %lld ))",dateLastTime,dateLastTime,dateFirstTime,dateFirstTime,dateLastTime,dateFirstTime,dateLastTime,dateLastTime,dateFirstTime,dateFirstTime,dateLastTime,dateFirstTime];
    RLMResults *calendarResult = [Calendar objectsInRealm:_rlmRealm where:resultStr];
    for (int index = 0;index < calendarResult.count;index ++) {
        Calendar *company = [calendarResult objectAtIndex:index];
        if(company.status != 0)
            [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//获取所有未删除的日程
- (NSMutableArray<Calendar*>*)getCalendarArr {
    NSMutableArray<Calendar*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [Calendar allObjectsInRealm:_rlmRealm];
    for (int index = 0;index < pushMessages.count;index ++) {
        Calendar *company = [pushMessages objectAtIndex:index];
        if (company.status != 0)
            [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//创建日程数据监听
- (RBQFetchedResultsController*)createCalendarFetchedResultsController {
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Calendar" inRealm:_rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- SignIn
//添加签到记录
- (void)addSigin:(SignIn*)signIn {
    [_rlmRealm beginWriteTransaction];
    [SignIn createOrUpdateInRealm:_rlmRealm withValue:signIn];
    [_rlmRealm commitWriteTransaction];
}
//更新今天的签到记录
- (void)updateTodaySinInList:(NSMutableArray<SignIn*>*)sigInArr guid:(NSString*)employeeGuid{
    [_rlmRealm beginWriteTransaction];
    NSDate *date = [NSDate date];
    int64_t dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    int64_t dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(employee_guid = %@ and create_on_utc >= %lld and create_on_utc <= %lld)",employeeGuid,dateFirstTime,dateLastTime];
    RLMResults *calendarResult = [SignIn objectsInRealm:_rlmRealm withPredicate:predicate];
    while (calendarResult.count) {
        [_rlmRealm deleteObject:calendarResult.firstObject];
    }
    for (SignIn *signIn in sigInArr) {
        [SignIn createOrUpdateInRealm:_rlmRealm withValue:signIn];
    }
    [_rlmRealm commitWriteTransaction];
}
//获取今天的签到记录
- (NSMutableArray<SignIn*>*)getTodaySigInListGuid:(NSString*)employeeGuid {
    NSMutableArray<SignIn*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    NSDate *date = [NSDate date];
    int64_t dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    int64_t dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(employee_guid = %@ and create_on_utc >= %lld and create_on_utc <= %lld)",employeeGuid,dateFirstTime,dateLastTime];
    RLMResults *calendarResult = [SignIn objectsInRealm:_rlmRealm withPredicate:predicate];
    for (int index = 0;index < calendarResult.count;index ++) {
        SignIn *company = [calendarResult objectAtIndex:index];
        [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//创建日程数据监听
- (RBQFetchedResultsController*)createSigInListFetchedResultsController:(NSString*)employeeGuid {
    RBQFetchedResultsController *fetchedResultsController = nil;
    NSDate *date = [NSDate date];
    int64_t dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    int64_t dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(employee_guid = %@ and create_on_utc >= %lld and create_on_utc <= %lld)",employeeGuid,dateFirstTime,dateLastTime];
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"SignIn" inRealm:_rlmRealm predicate:predicate];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- SiginRuleSet
//更新签到规则
- (void)updateSiginRule:(SiginRuleSet*)siginRule {
    [_rlmRealm beginWriteTransaction];
    [SiginRuleSet createOrUpdateInRealm:_rlmRealm withValue:siginRule];
    [_rlmRealm commitWriteTransaction];
}
//添加签到规则
- (void)addSiginRule:(SiginRuleSet*)siginRule {
    [_rlmRealm beginWriteTransaction];
    [SiginRuleSet createOrUpdateInRealm:_rlmRealm withValue:siginRule];
    [_rlmRealm commitWriteTransaction];
}
//删除签到规则
- (void)deleteSiginRule:(SiginRuleSet*)siginRule {
    [_rlmRealm beginWriteTransaction];
    [_rlmRealm deleteObject:siginRule];
    [_rlmRealm commitWriteTransaction];
}
//获取圈子的所有签到规则
- (NSMutableArray<SiginRuleSet*>*)getSiginRule:(int)companyNo {
    NSMutableArray *array = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d )",companyNo];
    RLMResults *calendarResult = [SiginRuleSet objectsInRealm:_rlmRealm withPredicate:predicate];
    for (int i = 0; i < calendarResult.count; i ++) {
        [array addObject:[calendarResult objectAtIndex:i]];
    }
    [_rlmRealm commitWriteTransaction];
    return array;
}
//更新圈子的所有签到规则
- (void)updateSiginRule:(NSMutableArray<SiginRuleSet*>*)sigRules companyNo:(int)companyNo {
    [_rlmRealm beginWriteTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d )",companyNo];
    RLMResults *calendarResult = [SiginRuleSet objectsInRealm:_rlmRealm withPredicate:predicate];
    while (calendarResult.count) {
        [_rlmRealm deleteObject:calendarResult.firstObject];
    }
    for (SiginRuleSet *siginRuleSet in sigRules) {
        [SiginRuleSet createOrUpdateInRealm:_rlmRealm withValue:siginRuleSet];
    }
    [_rlmRealm commitWriteTransaction];
}
//创建圈子的数据监听
- (RBQFetchedResultsController*)createSiginRuleFetchedResultsController:(int)companyNo {
    RBQFetchedResultsController *fetchedResultsController = nil;
     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d )",companyNo];
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"SiginRuleSet" inRealm:_rlmRealm predicate:predicate];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
#pragma mark -- TaskModel
//添加任务
- (void)addTask:(TaskModel*)model {
    [_rlmRealm beginWriteTransaction];
    [TaskModel createOrUpdateInRealm:_rlmRealm withValue:model];
    [_rlmRealm commitWriteTransaction];
}
//更新任务
- (void)upadteTask:(TaskModel*)model {
    [_rlmRealm beginWriteTransaction];
    [TaskModel createOrUpdateInRealm:_rlmRealm withValue:model];
    [_rlmRealm commitWriteTransaction];
}
//更新圈子的任务
- (void)updateTask:(NSMutableArray<TaskModel*>*)taskArr companyNo:(int)companyNo {
    [_rlmRealm beginWriteTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d )",companyNo];
    RLMResults *calendarResult = [TaskModel objectsInRealm:_rlmRealm withPredicate:predicate];
    while (calendarResult.count) {
        [_rlmRealm deleteObject:calendarResult.firstObject];
    }
    for (TaskModel *model in taskArr) {
        [TaskModel createOrUpdateInRealm:_rlmRealm withValue:model];
    }
    [_rlmRealm commitWriteTransaction];
}
//获取所有的任务列表
- (NSMutableArray<TaskModel*>*)getTaskArr:(int)companyNo {
    NSMutableArray<TaskModel*> *pushMessageArr = [@[] mutableCopy];
    [_rlmRealm beginWriteTransaction];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"company_no = %d and status != 0",companyNo];
    RLMResults *results = [[TaskModel objectsInRealm:_rlmRealm withPredicate:pred] sortedResultsUsingProperty:@"createdon_utc" ascending:NO];
    for (int index = 0;index < results.count;index ++) {
        TaskModel *company = [results objectAtIndex:index];
        [pushMessageArr addObject:company];
    }
    [_rlmRealm commitWriteTransaction];
    return pushMessageArr;
}
//任务数据监听
- (RBQFetchedResultsController*)createTaskFetchedResultsController:(int)companyNo {
    RBQFetchedResultsController *fetchedResultsController = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d and status != 0)",companyNo];
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"TaskModel" inRealm:_rlmRealm predicate:predicate];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController;
}
@end
