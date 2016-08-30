//
//  PushMessageOpertion.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "PushMessageOpertion.h"
#import "IdentityManager.h"
#import "NoResultView.h"
#import "PushMessageCell.h"
#import "BushManageViewController.h"
#import "RequestManagerController.h"
#import "TaskDetailController.h"
#import "WebNonstandarViewController.h"

@interface PushMessageOpertion () {
    UserManager *_userManager;
    NSMutableArray<PushMessage*> *_pushMessageArr;//搜索视图的数据
    NoResultView *_noDataView;//没有数据的视图
    IdentityManager *_identityManager;
}

@end

@implementation PushMessageOpertion
- (void)startConnect {
    _userManager = [UserManager manager];
    _identityManager = [IdentityManager manager];
    //创建空太图
    _noDataView = [[NoResultView alloc] initWithFrame:self.pushMessageController.tableView.bounds];
    [self searchDataFormLoc];
    if(_pushMessageArr.count == 0)
        self.pushMessageController.tableView.tableFooterView = _noDataView;
    else
        self.pushMessageController.tableView.tableFooterView = [UIView new];
    [self.pushMessageController.tableView reloadData];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [self searchDataFormLoc];
    if(_pushMessageArr.count == 0)
        self.pushMessageController.tableView.tableFooterView = _noDataView;
    else
        self.pushMessageController.tableView.tableFooterView = [UIView new];
    [self.pushMessageController.tableView reloadData];
}
//从本地搜索数据
- (void)searchDataFormLoc {
    NSMutableArray *array = [_userManager getPushMessageArr];
    if([NSString isBlank:self.pushMessageController.searchBar.text])
        _pushMessageArr = array;
    else {
        NSMutableArray *currArr = [@[] mutableCopy];
        for (PushMessage *message in array) {
            if([message.content rangeOfString:self.pushMessageController.searchBar.text].location != NSNotFound)
                [currArr addObject:message];
        }
        _pushMessageArr = currArr;
    }
    //按照时间降序排列
    [_pushMessageArr sortUsingComparator:^NSComparisonResult(PushMessage *obj1, PushMessage *obj2) {
        return obj1.addTime.timeIntervalSince1970 < obj2.addTime.timeIntervalSince1970;
    }];
}
#pragma mark --
#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.pushMessageController.searchBar endEditing:YES];
    [self searchDataFormLoc];
    [self.pushMessageController.tableView reloadData];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([NSString isBlank:[_pushMessageArr[indexPath.row] content]])
        return [@"会议有新的消息" textSizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 113, 10000)].height + 40;
    return [[_pushMessageArr[indexPath.row] content] textSizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 113, 10000)].height + 40;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _pushMessageArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PushMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushMessageCell" forIndexPath:indexPath];
    cell.data = _pushMessageArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.alpha = 0;
    [UIView animateWithDuration:0.6 animations:^{
        cell.alpha = 1;
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.editing == YES)
        return;
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        PushMessage *message = [_pushMessageArr[indexPath.row] deepCopy];
        if(message.unread == YES) {
            message.unread = NO;
            [_userManager updatePushMessage:message];
        }
        //分别进入对应的界面进行操作
        //如果是圈子操作
        if([message.type isEqualToString:@"COMPANY"]) {
            if([message.action isEqualToString:@"GENERAL"]) {
                for (Company *company in [_userManager getCompanyArr]) {
                    if(company.company_no == message.company_no) {
                        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
                        if(employee.status == 1 || employee.status == 4) {
                            User *user = [_userManager.user deepCopy];
                            user.currCompany = [company deepCopy];
                            [_userManager updateUser:user];
                        }
                        break;
                    }
                }
                if(_userManager.user.currCompany.company_no == 0) {
                    [self.pushMessageController.navigationController showMessageTips:@"请选择圈子后再操作"];
                }
                [self.pushMessageController.navigationController pushViewController:[RequestManagerController new] animated:YES];
            } else {
                [self.pushMessageController.navigationController pushViewController:[BushManageViewController new] animated:YES];
            }
        } else if ([message.type isEqualToString:@"TASK"]) {//如果是任务
            //进入任务详情
            for (TaskModel *model in [_userManager getTaskArr:message.company_no]) {
                if(model.id == message.target_id.intValue) {
                    TaskDetailController *task = [TaskDetailController new];
                    task.data = model;
                    [self.pushMessageController.navigationController pushViewController:task animated:YES];
                    break;
                }
            }
        } else if ([message.type isEqualToString:@"TASK_COMMENT_STATUS"]) {//如果是任务讨论信息变了
            for (TaskModel *model in [_userManager getTaskArr:message.company_no]) {
                if(model.id == message.target_id.intValue) {
                    TaskDetailController *task = [TaskDetailController new];
                    task.data = model;
                    [self.pushMessageController.navigationController pushViewController:task animated:YES];
                    break;
                }
            }
        }  else if ([message.type isEqualToString:@"CALENDAR"]) {//日程分享
            NSData *calendarData = [message.entity dataUsingEncoding:NSUTF8StringEncoding];
            NSMutableDictionary *calendarDic = [NSJSONSerialization JSONObjectWithData:calendarData options:NSJSONReadingMutableContainers error:nil];
            Calendar *sharedCalendar = [[Calendar alloc] initWithJSONDictionary:calendarDic];
            sharedCalendar.descriptionStr = calendarDic[@"description"];
            //展示详情
            if(sharedCalendar.repeat_type == 0) {
                Calendar *tempTemp = [sharedCalendar deepCopy];
                tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                [self.pushMessageController.navigationController pushControler:@"ComCalendarDetailViewController" parameters:@{@"calendar":tempTemp}];
            } else {
                Calendar *tempTemp = [sharedCalendar deepCopy];
                tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                [self.pushMessageController.navigationController pushControler:@"RepCalendarDetailController" parameters:@{@"calendar":tempTemp}];
            }
        } else if ([message.type isEqualToString:@"CALENDARTIP"]) {//日程推送：
            NSArray<Calendar*> *calendarArr = [[UserManager manager] getCalendarArr];
            for (Calendar *temp in calendarArr) {
                if(message.target_id.intValue == temp.id) {
                    //展示详情
                    if(temp.repeat_type == 0) {
                        Calendar *tempTemp = [temp deepCopy];
                        tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                        [self.pushMessageController.navigationController pushControler:@"ComCalendarDetailViewController" parameters:@{@"calendar":tempTemp}];
                    } else {
                        Calendar *tempTemp = [temp deepCopy];
                        tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                        [self.pushMessageController.navigationController pushControler:@"RepCalendarDetailController" parameters:@{@"calendar":tempTemp}];
                    }
                    break;
                }
            }
        } else if ([message.type isEqualToString:@"TASKTIP"]) {//任务提醒推送
            //进入任务详情
            for (TaskModel *model in [_userManager getTaskArr:message.company_no]) {
                if(model.id == message.target_id.intValue) {
                    TaskDetailController *task = [TaskDetailController new];
                    task.data = model;
                    [self.pushMessageController.navigationController pushViewController:task animated:YES];
                    break;
                }
            }
        }//网页
        else if ([message.type isEqualToString:@"REQUEST"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@request/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%d",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
            [self.pushMessageController.navigationController pushViewController:webViewcontroller animated:YES];
        } else if ([message.type isEqualToString:@"APPROVAL"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Approval/Details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%d",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
            [self.pushMessageController.navigationController pushViewController:webViewcontroller animated:YES];
        } else if ([message.type isEqualToString:@"NEW_APPROVAL"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@ApprovalByFormBuilder/Details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%d",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
            [self.pushMessageController.navigationController pushViewController:webViewcontroller animated:YES];
        } else if([message.type isEqualToString:@"MAIL"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Mail/Details?id=%@&isSend=false&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.pushMessageController.navigationController pushViewController:webViewcontroller animated:YES];
        } else if([message.type isEqualToString:@"MEETING"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Meeting/Details?id=%@&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.pushMessageController.navigationController pushViewController:webViewcontroller animated:YES];
        } else if([message.type isEqualToString:@"VOTE"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Vote/Details?id=%@&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.pushMessageController.navigationController pushViewController:webViewcontroller animated:YES];
        } else if([message.type isEqualToString:@"NOTICE"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@NOTICE/Details?id=%@&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.pushMessageController.navigationController pushViewController:webViewcontroller animated:YES];
        } else if ([message.type isEqualToString:@"WORK_ORDER"]) {
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@workorder/ClientDetails?id=%@&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.pushMessageController.navigationController pushViewController:webViewcontroller animated:YES];
        }
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing){
        return UITableViewCellEditingStyleDelete| UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleNone;
}
@end
