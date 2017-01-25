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
#define LocNotifotionDays 7

//由于realm删除操作只能删除读出来的数据，而修改需要重新copy一份，所以我们这里做一个操作，读出来的数据全部copy，然后删除操作重新读起再删除
@interface UserManager () {
    NSString *_pathUrl;
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
#pragma mark -- 本地推送
- (void)addSiginRuleNotfition {
    @synchronized (self) {
    //单独开启一个线程来操作数据库
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
        //清除本地没有触发的签到规则推送
        NSArray<UILocalNotification *> *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *cation in scheduledLocalNotifications) {
            if([cation.alertBody containsString:@"上下班提醒"]) {
                //如果是本地推送，看看触发时间，如果大于现在就删除
                NSDictionary *userInfo = cation.userInfo;
                PushMessage *message = [PushMessage new];
                [message mj_setKeyValues:userInfo];
                if(message.id.doubleValue > 0)
                    if(message.addTime.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970)
                        [self deletePushMessage:message];
                [[UIApplication sharedApplication] cancelLocalNotification:cation];
            }
        }
        //获取签到规则
        NSMutableArray<SiginRuleSet*> *siginModelArr = [@[] mutableCopy];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d)",_user.currCompany.company_no];
        RLMResults *calendarResult = [SiginRuleSet objectsInRealm:rlmRealm withPredicate:predicate];
        for (int i = 0; i < calendarResult.count; i ++) {
            [siginModelArr addObject:[calendarResult objectAtIndex:i]];
        }
        if(siginModelArr.count == 0) return;
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
            //当天上班时间
            NSDate *currUpTime = [NSDate dateWithTimeIntervalSince1970:today + index * 24 * 60 * 60 + begin];
            //如果设置了当天提醒
            if([weekArr containsObject:[NSString stringWithFormat:@"%ld",currUpTime.weekday]]) {
                //如果小于现在 去掉
                if([currUpTime timeIntervalSinceDate:[NSDate date]] < 0) {}
                else [self addUpDownWorkLocNoti:model date:currUpTime type:0];
            }
            //当天下班时间
            NSDate *currEndTime = [NSDate dateWithTimeIntervalSince1970:today + index * 24 * 60 * 60 + end];
            //如果设置了当天提醒
            if([weekArr containsObject:[NSString stringWithFormat:@"%ld",currEndTime.weekday]]) {
                //如果小于现在 去掉
                if([currEndTime timeIntervalSinceDate:[NSDate date]] < 0) {}
                else [self addUpDownWorkLocNoti:model date:currEndTime type:1];
            }
        }
    });
    }
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
        if(siginRule.start_work_time_alert != 0)
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
    [aUserInfo setObject:@(date.timeIntervalSince1970) forKey:@"id"];
    [aUserInfo setObject:date forKey:@"addTime"];
    [aUserInfo setObject:@(YES) forKey:@"unread"];
    [aUserInfo setObject:@(_user.currCompany.company_no) forKey:@"company_no"];
    notification.userInfo = aUserInfo;
    // 将通知添加到系统中
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //添加一个本地推送数据
    PushMessage *message = [PushMessage new];
    [message mj_setKeyValues:aUserInfo];
    [[UserManager manager] addPushMessage:message];
}
- (void)addCalendarNotfition {
    @synchronized (self) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
        //清除本地日程推送
        NSArray<UILocalNotification *> *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *cation in scheduledLocalNotifications) {
            if([cation.alertBody containsString:@"事务提醒"]) {
                //如果是本地推送，看看触发时间，如果大于现在就删除
                NSDictionary *userInfo = cation.userInfo;
                PushMessage *message = [PushMessage new];
                [message mj_setKeyValues:userInfo];
                if(message.id.doubleValue > 0)
                    if(message.addTime.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970)
                        [self deletePushMessage:message];
                [[UIApplication sharedApplication] cancelLocalNotification:cation];
            }
        }
        //获取本地5天内的日程
        NSDate *date = [NSDate date];
        for (int index = 0; index < LocNotifotionDays; index ++) {
            NSDate *currDate = [date dateByAddingTimeInterval:index * 24 * 60 * 60];
            NSMutableArray<Calendar*> *calendarArr = [@[] mutableCopy];
            RLMResults *calendarResult = [Calendar allObjectsInRealm:rlmRealm];
            for (int index = 0;index < calendarResult.count;index ++) {
                Calendar *company = [calendarResult objectAtIndex:index];
                int64_t todayBegin = date.firstTime.timeIntervalSince1970 * 1000;
                int64_t todayEnd = date.lastTime.timeIntervalSince1970 * 1000;
                if(company.repeat_type == 0) {//如果是不重复的 就判断时间是不是在其中
                    if(company.enddate_utc < todayBegin) continue;
                    if(company.begindate_utc > todayEnd) continue;
                    [calendarArr addObject:company];
                } else {//重复的就要看重复时间是不是在其中
                    //#warning 这里暂时处理一下，不知道怎么被修改的
                    Calendar *tempCompany = [company deepCopy];
                    tempCompany.rrule = [tempCompany.rrule stringByReplacingOccurrencesOfString:@":" withString:@"="];
                    if([NSString isBlank:company.rrule]) continue;
                    if(tempCompany.r_end_date_utc < todayBegin) continue;
                    if(tempCompany.r_begin_date_utc > todayEnd) continue;
                    [calendarArr addObject:tempCompany];
                }
            }
            //一天一天的加本地推送
            for (Calendar *calendar in calendarArr) {
                if(calendar.status == 2 || calendar.status == 0) continue;//如果已经完成/已经删除就不添加
                if(calendar.repeat_type == 0) {//如果是不重复的日程
                    if(calendar.alert_minutes_before != 0) {//有没有事前提醒
                        NSDate *alertBeforeDate = [NSDate dateWithTimeIntervalSince1970:calendar.begindate_utc / 1000 - calendar.alert_minutes_before * 60];
                        //只添加当天的
                        if(alertBeforeDate.day != currDate.day) continue;
                        if(alertBeforeDate.timeIntervalSince1970 < date.timeIntervalSince1970) { } else {
                            //添加到本地推送
                            [self addCalendarAlertToLocNoti:calendar date:alertBeforeDate];
                        }
                    }
                    if(calendar.alert_minutes_after != 0) {//有没有事后提醒
                        NSDate *alertAfterDate = [NSDate dateWithTimeIntervalSince1970:calendar.enddate_utc / 1000 + calendar.alert_minutes_after * 60];
                        //只添加当天的
                        if(alertAfterDate.day != currDate.day) continue;
                        if(alertAfterDate.timeIntervalSince1970 < date.timeIntervalSince1970) { } else {
                            //添加到本地推送
                            [self addCalendarAlertToLocNoti:calendar date:alertAfterDate];
                        }
                    }
                } else {//如果是重复的日程
                    if(calendar.rrule.length > 0 && calendar.r_begin_date_utc>0 && calendar.r_end_date_utc > 0) {
                        if(calendar.alert_minutes_before != 0) {//有没有事前提醒
                            //这里计算出循环开始当天的时间
                            int64_t second = calendar.r_begin_date_utc / 1000;
                            second = second / (24 * 60 * 60) * (24 * 60 * 60);
                            second += (calendar.begindate_utc / 1000) % (24 * 60 * 60);
                            Scheduler * scheduler = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:second] andRule:calendar.rrule];
                            //得到今天所有的时间
                            NSArray * occurences = [scheduler occurencesBetween:currDate.firstTime andDate:currDate.lastTime];
                            //遍历所有的时间
                            for (NSDate *dddd in occurences) {
                                //只添加当天的
                                if(dddd.day != currDate.day) continue;
                                //这个库算出来的结果可能会有之前的时间，现在去掉
                                if([dddd timeIntervalSince1970] < calendar.r_begin_date_utc/1000) {
                                    continue;
                                } else if([dddd timeIntervalSince1970] > calendar.r_end_date_utc/1000){
                                    //这个库算出来的结果可能会有之后的时间，现在去掉
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
                        if(calendar.alert_minutes_after != 0) {//有没有事后提醒
                            //这里计算出循环开始当天的时间
                            int64_t second = calendar.r_begin_date_utc / 1000;
                            second = second / (24 * 60 * 60) * (24 * 60 * 60);
                            second += (calendar.begindate_utc / 1000) % (24 * 60 * 60);
                            Scheduler * scheduler = [[Scheduler alloc] initWithDate:[NSDate dateWithTimeIntervalSince1970:second] andRule:calendar.rrule];
                            //得到今天所有的时间
                            NSArray * occurences = [scheduler occurencesBetween:currDate.firstTime andDate:currDate.lastTime];
                            //遍历所有的时间
                            for (NSDate *dddd in occurences) {
                                //只添加当天的
                                if(dddd.day != currDate.day) continue;
                                //这个库算出来的结果可能会有之前的时间，现在去掉
                                if([dddd timeIntervalSince1970] < calendar.r_begin_date_utc/1000) {
                                    continue;
                                } else if([dddd timeIntervalSince1970] > calendar.r_end_date_utc/1000){ //这个库算出来的结果可能会有之后的时间，现在去掉
                                    continue;
                            }else if ([calendar haveDeleteDate:currDate]) {
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
            }
            [calendarArr removeAllObjects];
            calendarArr = nil;
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
    [aUserInfo setObject:date forKey:@"addTime"];
    [aUserInfo setObject:@(YES) forKey:@"unread"];
    [aUserInfo setObject:@(date.timeIntervalSince1970) forKey:@"id"];
    [aUserInfo setObject:@"GENERAL" forKey:@"action"];
    [aUserInfo setObject:@(_user.currCompany.company_no) forKey:@"company_no"];
    notification.userInfo = aUserInfo;
    // 将通知添加到系统中
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //添加一个本地推送数据
    PushMessage *message = [PushMessage new];
    [message mj_setKeyValues:aUserInfo];
    [[UserManager manager] addPushMessage:message];
}
- (void)addTaskNotfition {
    @synchronized (self) {
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
        //清除本地任务推送
        NSArray<UILocalNotification *> *scheduledLocalNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *cation in scheduledLocalNotifications) {
        if([cation.alertBody containsString:@"任务提醒"]) {
            //如果是本地推送，看看触发时间，如果大于现在就删除
            NSDictionary *userInfo = cation.userInfo;
            PushMessage *message = [PushMessage new];
            [message mj_setKeyValues:userInfo];
            if(message.id.doubleValue > 0)
                if(message.addTime.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970)
                    [self deletePushMessage:message];
            [[UIApplication sharedApplication] cancelLocalNotification:cation];
        }
    }
    //添加5天内的任务推送
    NSMutableArray<TaskModel*> *taskArr = [@[] mutableCopy];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"company_no = %d",_user.currCompany.company_no];
        RLMResults *results = [[TaskModel objectsInRealm:rlmRealm withPredicate:pred] sortedResultsUsingProperty:@"createdon_utc" ascending:NO];
        for (int index = 0;index < results.count;index ++) {
            TaskModel *company = [results objectAtIndex:index];
            [taskArr addObject:company];
        }
        NSDate *currDate = [NSDate date];
        for (TaskModel *model in taskArr) {
            if(model.status == 0 || model.status == 1 || model.status == 7 || model.status == 8) continue;//去掉不提醒的 删除 未接受 已终止 已完结
            if([NSString isBlank:model.alert_date_list]) continue;//去掉没有提醒时间的
            NSArray *alertStrArr = [model.alert_date_list componentsSeparatedByString:@","];
            for (NSString *str in alertStrArr) {
                NSDate *currAlertDate = [NSDate dateWithTimeIntervalSince1970:str.doubleValue / 1000];
                if(currAlertDate.timeIntervalSince1970 < currDate.timeIntervalSince1970) continue;
                if((currAlertDate.timeIntervalSince1970 - currDate.timeIntervalSince1970) <= (LocNotifotionDays * 24 * 60 * 60)) {//得到在提醒天数之内的时间
                    [self addTaskAlertToLocNoti:model date:currAlertDate];
                }
            }
        }
        [taskArr removeAllObjects];
        taskArr = nil;
    });
    }
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
    [aUserInfo setObject:@(date.timeIntervalSince1970).stringValue forKey:@"id"];
    [aUserInfo setObject:date forKey:@"addTime"];
    [aUserInfo setObject:@(YES) forKey:@"unread"];
    [aUserInfo setObject:@"GENERAL" forKey:@"action"];
    notification.userInfo = aUserInfo;
    // 将通知添加到系统中
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //添加一个本地推送数据
    PushMessage *message = [PushMessage new];
    [message mj_setKeyValues:aUserInfo];
    [[UserManager manager] addPushMessage:message];
}
#pragma mark -- User
//更新用户数据
- (void)updateUser:(User*)user {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [User createOrUpdateInRealm:rlmRealm withValue:user];
    self.user = user;
    [rlmRealm commitWriteTransaction];
    //把用户数据放到应用组间共享数据
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.lottak.bangbang"];
    UserInfo *userInfo = [UserInfo new];
    userInfo.user_guid = _user.user_guid;
    [NSKeyedArchiver setClassName:@"UserInfo" forClass:[UserInfo class]];
    [sharedDefaults setValue:[NSKeyedArchiver archivedDataWithRootObject:userInfo] forKey:@"GroupUserInfo"];
    [sharedDefaults synchronize];
    }
}
//通过用户guid加载用户
- (void)loadUserWithGuid:(NSString*)userGuid {
    @synchronized (self) {
    //得到用户对应的数据库路径
    NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    _pathUrl = pathArr[0];
    _pathUrl = [_pathUrl stringByAppendingPathComponent:userGuid];
    //创建数据库
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    //得到/创建用户数据
    RLMResults *users = [User allObjectsInRealm:rlmRealm];
    if(users.count) {
        self.user = [[users objectAtIndex:0] deepCopy];
    } else {
        self.user = [User new];
    }
    }
}
//创建用户的数据库观察者
- (RBQFetchedResultsController*)createUserFetchedResultsController {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"User" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
//获取所有员工
- (NSMutableArray<Employee*>*)getEmployeeArr {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RLMResults *results = [Employee objectsInRealm:rlmRealm withPredicate:nil];
    NSMutableArray *array = [@[] mutableCopy];
    for (int index = 0; index < results.count; index ++) {
        [array addObject:[[results objectAtIndex:index] deepCopy]];
    }
    return array;
}
//根据Guid和圈子ID获取员工
- (Employee*)getEmployeeWithGuid:(NSString*)userGuid companyNo:(int)companyNo {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSPredicate *pred  = [NSPredicate predicateWithFormat:@"user_guid = %@ and company_no = %d",userGuid,companyNo];
    RLMResults *results = [Employee objectsInRealm:rlmRealm withPredicate:pred];
    //如果有值就返回 没有就算了
    if(results.count)
        return [[results objectAtIndex:0] deepCopy];
    return [Employee new];
}
#pragma mark -- Company
//添加某个圈子
- (void)addCompany:(Company*)company {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [Company createOrUpdateInRealm:rlmRealm withValue:company];
    [rlmRealm commitWriteTransaction];
    }
}
//删除某个圈子
- (void)deleteCompany:(Company*)company {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    //重新读取一次 再删除
    NSPredicate *pred  = [NSPredicate predicateWithFormat:@"company_no = %d",company.company_no];
    RLMResults *results = [Company objectsInRealm:rlmRealm withPredicate:pred];
    if(results.count > 0)
        [rlmRealm deleteObject:results.firstObject];
    [rlmRealm commitWriteTransaction];
    }
}
//更新某个圈子信息
- (void)updateCompany:(Company*)company {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [Company createOrUpdateInRealm:rlmRealm withValue:company];
    [rlmRealm commitWriteTransaction];
    }
}
//更新所有圈子数据
- (void)updateCompanyArr:(NSArray<Company*>*)companyArr {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    for (Company *company in companyArr) {
        [Company createOrUpdateInRealm:rlmRealm withValue:company];
    }
    [rlmRealm commitWriteTransaction];
    }
}
//获取圈子数组
- (NSMutableArray<Company*>*)getCompanyArr {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray<Company*> *companyArr = [@[] mutableCopy];
    RLMResults *companys = [Company allObjectsInRealm:rlmRealm];
    for (int index = 0;index < companys.count;index ++) {
        Company *company = [companys objectAtIndex:index];
        [companyArr addObject:[company deepCopy]];
    }
    return companyArr;
}
//创建圈子的数据库观察者
- (RBQFetchedResultsController*)createCompanyFetchedResultsController {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Company" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
#pragma mark -- Employee
//更新某个员工
- (void)updateEmployee:(Employee*)emplyee {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [Employee createOrUpdateInRealm:rlmRealm withValue:emplyee];
    [rlmRealm commitWriteTransaction];
    }
}
//根据圈子ID更新所有员工信息
- (void)updateEmployee:(NSMutableArray<Employee*>*)employeeArr companyNo:(int)companyNo{
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    NSPredicate *pred = nil;
    //如果有圈子id就查询指定圈子员工 如果有状态就查询状态
    if(companyNo)
        pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
    RLMResults *results = [Employee objectsInRealm:rlmRealm withPredicate:pred];
    while (results.count)
        [rlmRealm deleteObject:results.firstObject];
    for (Employee * employee in employeeArr) {
        [Employee createOrUpdateInRealm:rlmRealm withValue:employee];
    }
    [rlmRealm commitWriteTransaction];
    }
}
//根据圈子ID获取员工信息
- (NSMutableArray<Employee*>*)getEmployeeWithCompanyNo:(int)companyNo status:(int)status{
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray *array = [@[] mutableCopy];
    NSPredicate *pred = nil;
    //如果有圈子id就查询指定圈子员工 如果有状态就查询状态 5查询在职 -1 查询所有
    if(status == -1) {
        pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
    } else if(status == 5) {
        pred = [NSPredicate predicateWithFormat:@"company_no = %d and (status = 1 or status = 4)",companyNo];
    } else {
        pred = [NSPredicate predicateWithFormat:@"company_no = %d and status = %d",companyNo,status];
    }
    RLMResults *results = [Employee objectsInRealm:rlmRealm withPredicate:pred];
    for (int index = 0;index < results.count;index ++) {
        Employee *employee = [results objectAtIndex:index];
        [array addObject:[employee deepCopy]];
    }
    return array;
    }
}
//根据圈子和状态创建数据库监听
- (RBQFetchedResultsController*)createEmployeesFetchedResultsControllerWithCompanyNo:(int)companyNo {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    NSPredicate *pred = nil;
    pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Employee" inRealm:rlmRealm predicate:pred];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
#pragma mark -- PushMessage
//添加某个推送消息
- (void)addPushMessage:(PushMessage*)pushMessage {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [PushMessage createOrUpdateInRealm:rlmRealm withValue:pushMessage];
    [rlmRealm commitWriteTransaction];
    }
}
//修改某个推送消息
- (void)updatePushMessage:(PushMessage*)pushMessage {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [PushMessage createOrUpdateInRealm:rlmRealm withValue:pushMessage];
    [rlmRealm commitWriteTransaction];
    }
}
//删除某个推送消息
- (void)deletePushMessage:(PushMessage*)pushMessage {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    //重新读取一次 再删除
    NSPredicate *pred  = [NSPredicate predicateWithFormat:@"id = %@",pushMessage.id];
    RLMResults *results = [PushMessage objectsInRealm:rlmRealm withPredicate:pred];
    if(results.count > 0)
        [rlmRealm deleteObject:results.firstObject];
    [rlmRealm commitWriteTransaction];
    }
}
//获取所有的推送消息
- (NSMutableArray<PushMessage*>*)getPushMessageArr {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray<PushMessage*> *pushMessageArr = [@[] mutableCopy];
    RLMResults *pushMessages = [PushMessage allObjectsInRealm:rlmRealm];
    for (int index = 0;index < pushMessages.count;index ++) {
        PushMessage *company = [pushMessages objectAtIndex:index];
        [pushMessageArr addObject:[company deepCopy]];
    }
    return pushMessageArr;
}
//创建消息数据监听
- (RBQFetchedResultsController*)createPushMessagesFetchedResultsController {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"PushMessage" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
#pragma mark -- UserDiscuss
//添加通讯录中的讨论组
- (void)addUserDiscuss:(UserDiscuss*)userDiscuss {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [UserDiscuss createOrUpdateInRealm:rlmRealm withValue:userDiscuss];
    [rlmRealm commitWriteTransaction];
    }
}
//删除通讯录中的讨论组
- (void)deleteUserDiscuss:(UserDiscuss*)userDiscuss {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    //重新读取一次 再删除
    NSPredicate *pred  = [NSPredicate predicateWithFormat:@"id = %d",userDiscuss.id];
    RLMResults *results = [UserDiscuss objectsInRealm:rlmRealm withPredicate:pred];
    if(results.count > 0)
        [rlmRealm deleteObject:results.firstObject];
    [rlmRealm commitWriteTransaction];
    }
}
//更新所有讨论组
- (void)updateUserDiscussArr:(NSMutableArray<UserDiscuss*>*)userDiscussArr {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    RLMResults *pushMessages = [UserDiscuss allObjectsInRealm:rlmRealm];
    while (pushMessages.count)
        [rlmRealm deleteObject:pushMessages.firstObject];
    for (UserDiscuss *userDiscuss in userDiscussArr) {
        [UserDiscuss createOrUpdateInRealm:rlmRealm withValue:userDiscuss];
    }
    [rlmRealm commitWriteTransaction];
    }
}
//获取所有的讨论组
- (NSMutableArray<UserDiscuss*>*)getUserDiscussArr {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray<UserDiscuss*> *pushMessageArr = [@[] mutableCopy];
    RLMResults *pushMessages = [UserDiscuss allObjectsInRealm:rlmRealm];
    for (int index = 0;index < pushMessages.count;index ++) {
        UserDiscuss *company = [pushMessages objectAtIndex:index];
        [pushMessageArr addObject:[company deepCopy]];
    }
    return pushMessageArr;
}
//创建讨论组数据监听
- (RBQFetchedResultsController*)createUserDiscusFetchedResultsController {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"UserDiscuss" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
#pragma mark -- Calendar
//添加日程
- (void)addCalendar:(Calendar*)calendar {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [Calendar createOrUpdateInRealm:rlmRealm withValue:calendar];
    [rlmRealm commitWriteTransaction];
    }
}
//更新日程
- (void)updateCalendar:(Calendar*)calendar {
    @synchronized (self) {
    //#BANG-427 这里有一个BUG，一个循环日程 现在完成其中的某一天 再进入这一天的详情是可以删除的
    //这时候删除本天 更新数据库  结果把其他的所有天都完成了 因为那天的日程状态是已经完成的，更新状态也一起写入数据库了
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [Calendar createOrUpdateInRealm:rlmRealm withValue:calendar];
    [rlmRealm commitWriteTransaction];
    }
}
//更新所有的日程
- (void)updateCalendars:(NSMutableArray<Calendar*>*)calendarArr {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    RLMResults *rLMResults = [Calendar allObjects];
    while (rLMResults.count) {
        [rlmRealm deleteObject:rLMResults.firstObject];
    }
    for (Calendar *calendar in calendarArr) {
        [Calendar createOrUpdateInRealm:rlmRealm withValue:calendar];
    }
    [rlmRealm commitWriteTransaction];
    }
}
//获取指定时间的日程 未删除的
- (NSMutableArray<Calendar*>*)getCalendarArrWithDate:(NSDate*)date {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray<Calendar*> *pushMessageArr = [@[] mutableCopy];
    RLMResults *calendarResult = [Calendar allObjectsInRealm:rlmRealm];
    for (int index = 0;index < calendarResult.count;index ++) {
        Calendar *company = [calendarResult objectAtIndex:index];
        int64_t todayBegin = date.firstTime.timeIntervalSince1970 * 1000;
        int64_t todayEnd = date.lastTime.timeIntervalSince1970 * 1000;
        if(company.repeat_type == 0) {//如果是不重复的 就判断时间是不是在其中
            if(company.enddate_utc < todayBegin) continue;
            if(company.begindate_utc > todayEnd) continue;
            [pushMessageArr addObject:[company deepCopy]];
        } else {//重复的就要看重复时间是不是在其中
            //#warning 这里暂时处理一下，不知道怎么被修改的
            Calendar *tempCompany = [company deepCopy];
            tempCompany.rrule = [tempCompany.rrule stringByReplacingOccurrencesOfString:@":" withString:@"="];
            if([NSString isBlank:company.rrule]) continue;
            if(tempCompany.r_end_date_utc < todayBegin) continue;
            if(tempCompany.r_begin_date_utc > todayEnd) continue;
            [pushMessageArr addObject:tempCompany];
        }
    }
    return pushMessageArr;
}
//获取所有的日程
- (NSMutableArray<Calendar*>*)getCalendarArr {
    NSMutableArray<Calendar*> *pushMessageArr = [@[] mutableCopy];
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RLMResults *pushMessages = [Calendar allObjectsInRealm:rlmRealm];
    for (int index = 0;index < pushMessages.count;index ++) {
        Calendar *company = [pushMessages objectAtIndex:index];
        if(company.repeat_type == 0) {
            [pushMessageArr addObject:[company deepCopy]];
            continue;
        }
        //#warning 这里暂时处理一下，不知道怎么被修改的
        Calendar *tempCompany = [company deepCopy];
        tempCompany.rrule = [tempCompany.rrule stringByReplacingOccurrencesOfString:@":" withString:@"="];
        if([NSString isBlank:company.rrule]) continue;
        [pushMessageArr addObject:tempCompany];
    }
    return pushMessageArr;
}
//创建日程数据监听
- (RBQFetchedResultsController*)createCalendarFetchedResultsController {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"Calendar" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
#pragma mark -- SignIn
//添加签到记录
- (void)addSigin:(SignIn*)signIn {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [SignIn createOrUpdateInRealm:rlmRealm withValue:signIn];
    [rlmRealm commitWriteTransaction];
    }
}
//更新今天的签到记录
- (void)updateTodaySinInList:(NSMutableArray<SignIn*>*)sigInArr guid:(NSString*)employeeGuid{
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    NSDate *date = [NSDate date];
    int64_t dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    int64_t dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(employee_guid = %@ and create_on_utc >= %lld and create_on_utc <= %lld)",employeeGuid,dateFirstTime,dateLastTime];
    RLMResults *calendarResult = [SignIn objectsInRealm:rlmRealm withPredicate:predicate];
    while (calendarResult.count) {
        [rlmRealm deleteObject:calendarResult.firstObject];
    }
    for (SignIn *signIn in sigInArr) {
        [SignIn createOrUpdateInRealm:rlmRealm withValue:signIn];
    }
    [rlmRealm commitWriteTransaction];
    }
}
//获取今天的签到记录
- (NSMutableArray<SignIn*>*)getSigInListGuid:(NSString*)employeeGuid siginDate:(NSDate*)date{
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray<SignIn*> *pushMessageArr = [@[] mutableCopy];
    int64_t dateFirstTime = date.firstTime.timeIntervalSince1970 * 1000;
    int64_t dateLastTime = date.lastTime.timeIntervalSince1970 * 1000;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(employee_guid = %@ and create_on_utc >= %lld and create_on_utc <= %lld)",employeeGuid,dateFirstTime,dateLastTime];
    RLMResults *calendarResult = [SignIn objectsInRealm:rlmRealm withPredicate:predicate];
    for (int index = 0;index < calendarResult.count;index ++) {
        SignIn *company = [calendarResult objectAtIndex:index];
        [pushMessageArr addObject:[company deepCopy]];
    }
    return pushMessageArr;
}
//创建日程数据监听
- (RBQFetchedResultsController*)createSigInListFetchedResultsController {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"SignIn" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
#pragma mark -- SiginRuleSet
//更新签到规则
- (void)updateSiginRule:(SiginRuleSet*)siginRule {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [SiginRuleSet createOrUpdateInRealm:rlmRealm withValue:siginRule];
    [rlmRealm commitWriteTransaction];
    }
}
//添加签到规则
- (void)addSiginRule:(SiginRuleSet*)siginRule {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [SiginRuleSet createOrUpdateInRealm:rlmRealm withValue:siginRule];
    [rlmRealm commitWriteTransaction];
    }
}
//删除签到规则
- (void)deleteSiginRule:(SiginRuleSet*)siginRule {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    //重新读取一次 再删除
    NSPredicate *pred  = [NSPredicate predicateWithFormat:@"id = %d",siginRule.id];
    RLMResults *results = [SiginRuleSet objectsInRealm:rlmRealm withPredicate:pred];
    if(results.count > 0)
        [rlmRealm deleteObject:results.firstObject];
    [rlmRealm commitWriteTransaction];
    }
}
//获取圈子的所有签到规则
- (NSMutableArray<SiginRuleSet*>*)getSiginRule:(int)companyNo {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray *array = [@[] mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d)",companyNo];
    RLMResults *calendarResult = [SiginRuleSet objectsInRealm:rlmRealm withPredicate:predicate];
    for (int i = 0; i < calendarResult.count; i ++) {
        [array addObject:[[calendarResult objectAtIndex:i] deepCopy]];
    }
    return array;
}
//更新圈子的所有签到规则
- (void)updateSiginRule:(NSMutableArray<SiginRuleSet*>*)sigRules companyNo:(int)companyNo {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d)",companyNo];
    RLMResults *calendarResult = [SiginRuleSet objectsInRealm:rlmRealm withPredicate:predicate];
    while (calendarResult.count) {
        [rlmRealm deleteObject:calendarResult.firstObject];
    }
    for (SiginRuleSet *siginRuleSet in sigRules) {
        [SiginRuleSet createOrUpdateInRealm:rlmRealm withValue:siginRuleSet];
    }
    [rlmRealm commitWriteTransaction];
    }
}
//创建圈子的数据监听
- (RBQFetchedResultsController*)createSiginRuleFetchedResultsController {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"SiginRuleSet" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
#pragma mark -- TaskModel
//添加任务
- (void)addTask:(TaskModel*)model {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [TaskModel createOrUpdateInRealm:rlmRealm withValue:model];
    [rlmRealm commitWriteTransaction];
    }
}
//更新任务
- (void)upadteTask:(TaskModel*)model {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [TaskModel createOrUpdateInRealm:rlmRealm withValue:model];
    [rlmRealm commitWriteTransaction];
    }
}
//更新圈子的任务
- (void)updateTask:(NSMutableArray<TaskModel*>*)taskArr companyNo:(int)companyNo {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(company_no = %d)",companyNo];
    RLMResults *calendarResult = [TaskModel objectsInRealm:rlmRealm withPredicate:predicate];
    while (calendarResult.count) {
        [rlmRealm deleteObject:calendarResult.firstObject];
    }
    for (TaskModel *model in taskArr) {
        [TaskModel createOrUpdateInRealm:rlmRealm withValue:model];
    }
    [rlmRealm commitWriteTransaction];
    }
}
//获取所有的任务列表
- (NSMutableArray<TaskModel*>*)getTaskArr:(int)companyNo {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray<TaskModel*> *pushMessageArr = [@[] mutableCopy];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"company_no = %d",companyNo];
    RLMResults *results = [[TaskModel objectsInRealm:rlmRealm withPredicate:pred] sortedResultsUsingProperty:@"createdon_utc" ascending:NO];
    for (int index = 0;index < results.count;index ++) {
        TaskModel *company = [results objectAtIndex:index];
        [pushMessageArr addObject:[company deepCopy]];
    }
    return pushMessageArr;
}
//任务数据监听
- (RBQFetchedResultsController*)createTaskFetchedResultsController:(int)companyNo {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"TaskModel" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
#pragma mark -- TaskDraftModel
//存储任务草稿
- (void)updateTaskDraft:(TaskDraftModel*)taskDraftModel companyNo:(int)companyNo {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(company_no = %d)",companyNo];
    RLMResults *results = [TaskDraftModel objectsInRealm:rlmRealm withPredicate:pred];
    while (results.count)
        [rlmRealm deleteObject:results.firstObject];
    [TaskDraftModel createOrUpdateInRealm:rlmRealm withValue:taskDraftModel];
    [rlmRealm commitWriteTransaction];
    }
}
//删除任务草稿
- (void)deleteTaskDraft:(TaskDraftModel*)taskDraftModel {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    //重新读取一次 再删除
    NSPredicate *pred  = [NSPredicate predicateWithFormat:@"id = %d",taskDraftModel.id];
    RLMResults *results = [TaskDraftModel objectsInRealm:rlmRealm withPredicate:pred];
    if(results.count)
        [rlmRealm deleteObject:results.firstObject];
    [rlmRealm commitWriteTransaction];
    }
}
//读取任务草稿
- (NSMutableArray<TaskDraftModel*>*)getTaskDraftArr:(int)companyNo {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray<TaskDraftModel*> *pushMessageArr = [@[] mutableCopy];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(company_no = %d)",companyNo];
    RLMResults *results = [TaskDraftModel objectsInRealm:rlmRealm withPredicate:pred];
    for (int index = 0;index < results.count;index ++) {
        TaskDraftModel *company = [results objectAtIndex:index];
        [pushMessageArr addObject:[company deepCopy]];
    }
    return pushMessageArr;
}
//任务草稿数据监听
- (RBQFetchedResultsController*)createTaskDraftFetchedResultsController {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"TaskDraftModel" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
#pragma mark -- UserApp
//添加一个应用
- (void)addUserApp:(UserApp*)userApp {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    [UserApp createOrUpdateInRealm:rlmRealm withValue:userApp];
    [rlmRealm commitWriteTransaction];
    }
}
//删除一个应用
- (void)delUserApp:(UserApp*)userApp {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    //重新读取一次 再删除
    NSPredicate *pred  = [NSPredicate predicateWithFormat:@"app_guid = %@",userApp.app_guid];
    RLMResults *results = [UserApp objectsInRealm:rlmRealm withPredicate:pred];
    if(results.count > 0)
        [rlmRealm deleteObject:results.firstObject];
    [rlmRealm commitWriteTransaction];
    }
}
//更新所有应用
- (void)updateUserAppArr:(NSMutableArray<UserApp*>*)userAppArr {
    @synchronized (self) {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    [rlmRealm beginWriteTransaction];
    RLMResults *calendarResult = [UserApp objectsInRealm:rlmRealm withPredicate:nil];
    while (calendarResult.count) {
        [rlmRealm deleteObject:calendarResult.firstObject];
    }
    for (UserApp *model in userAppArr) {
        [UserApp createOrUpdateInRealm:rlmRealm withValue:model];
    }
    [rlmRealm commitWriteTransaction];
    }
}
//获取所有应用
- (NSMutableArray<UserApp*>*)getUserAppArr {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    NSMutableArray *pushMessageArr = [@[] mutableCopy];
    RLMResults *results = [UserApp objectsInRealm:rlmRealm withPredicate:nil];
    for (int index = 0;index < results.count;index ++) {
        UserApp *company = [results objectAtIndex:index];
        [pushMessageArr addObject:[company deepCopy]];
    }
    return pushMessageArr;
}
//应用数据监听
- (RBQFetchedResultsController*)createUserAppFetchedResultsController {
    RLMRealm *rlmRealm = [RLMRealm realmWithURL:[NSURL URLWithString:_pathUrl]];
    RBQFetchedResultsController *fetchedResultsController = nil;
    RBQFetchRequest *fetchRequest = [RBQFetchRequest fetchRequestWithEntityName:@"UserApp" inRealm:rlmRealm predicate:nil];
    fetchedResultsController = [[RBQFetchedResultsController alloc] initWithFetchRequest:fetchRequest sectionNameKeyPath:nil cacheName:nil];
    [fetchedResultsController performFetch];
    return fetchedResultsController ? : [RBQFetchedResultsController new];
}
@end
