//
//  PushMessageController.m
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "PushMessageController.h"
#import "PushMessageCell.h"
#import "WebNonstandarViewController.h"
#import "RequestManagerController.h"
#import "BushManageViewController.h"
#import "PushMessage.h"
#import "UserManager.h"
#import "IdentityManager.h"
#import "TaskDetailController.h"
#import "UserHttp.h"

#import "NoResultView.h"

@interface PushMessageController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;
    IdentityManager *_identityManager;
    UITableView *_tableView;//表格视图
    NSMutableArray<PushMessage*> *_pushMessageArr;//搜索视图的数据
    NoResultView *_noDataView;//没有数据的视图
    UISearchBar *_searchBar;//搜索视图
    RBQFetchedResultsController *_pushMessageFetchedResultsController;//推送消息数据监听
    BOOL isFirstLoad;
}

@end

@implementation PushMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    //创建搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    _searchBar.tintColor = [UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1];
    [_searchBar setSearchBarBackgroundColor:[UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1]];
    _searchBar.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:_searchBar];
    //创建导航栏
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"标记" style:UIBarButtonItemStylePlain target:self action:@selector(biaojiClicked:)];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //是不是第一次加载这个页面
    if(isFirstLoad) return;
    isFirstLoad = YES;
    
    _identityManager = [IdentityManager manager];
    _pushMessageFetchedResultsController = [_userManager createPushMessagesFetchedResultsController];
    _pushMessageFetchedResultsController.delegate = self;
    _pushMessageArr = [@[] mutableCopy];
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 55 - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[UINib nibWithNibName:@"PushMessageCell" bundle:nil] forCellReuseIdentifier:@"PushMessageCell"];
    [self.view addSubview:_tableView];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClicked:)];
    _tableView.userInteractionEnabled = YES;
    [_tableView addGestureRecognizer:lpgr];
    //创建空太图
    _noDataView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    [self searchDataFormLoc];
    if(_pushMessageArr.count == 0)
        _tableView.tableFooterView = _noDataView;
    else
        _tableView.tableFooterView = [UIView new];
    [_tableView reloadData];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [self searchDataFormLoc];
    if(_pushMessageArr.count == 0)
        _tableView.tableFooterView = _noDataView;
    else
        _tableView.tableFooterView = [UIView new];
    [_tableView reloadData];
}
//表格视图长按手势
- (void)longClicked:(UILongPressGestureRecognizer*)lpgr {
    if(lpgr.state == UIGestureRecognizerStateBegan) {
        if(_tableView.editing == YES) {
            _tableView.editing = NO;
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"标记" style:UIBarButtonItemStylePlain target:self action:@selector(biaojiClicked:)];
        } else {
            _tableView.editing = YES;
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancleClicked:)];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteClicked:)];
        }
    }
}
//删除已选中的项
- (void)deleteClicked:(UIBarButtonItem*)item {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"确定删除所选内容?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSArray *selectArr = _tableView.indexPathsForSelectedRows;
        selectArr = [selectArr sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath*  _Nonnull obj1, NSIndexPath*  _Nonnull obj2) {
            return obj1.row > obj2.row;
        }];
        for (int index = (int)selectArr.count - 1; index >= 0; index --) {
            NSIndexPath *indexPath = selectArr[index];
            PushMessage *message = _pushMessageArr[indexPath.row];
            [_userManager deletePushMessage:message];
        }
    }];
    [alertVC addAction:cancle];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//取消表格视图标记状态
- (void)cancleClicked:(UIBarButtonItem*)item {
    _tableView.editing = NO;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"标记" style:UIBarButtonItemStylePlain target:self action:@selector(biaojiClicked:)];
}
//全部标记信息
- (void)biaojiClicked:(UIBarButtonItem*)item {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"全部标记已读?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *array = [_userManager getPushMessageArr];
        for (PushMessage *pushMessage in array) {
            PushMessage *temp = [pushMessage deepCopy];
            temp.unread = NO;
            [_userManager updatePushMessage:temp];
        }
    }];
    [alertVC addAction:cancle];
    [alertVC addAction:ok];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//从本地搜索数据
- (void)searchDataFormLoc {
    NSMutableArray *array = [_userManager getPushMessageArr];
    if([NSString isBlank:_searchBar.text])
        _pushMessageArr = array;
    else {
         NSMutableArray *currArr = [@[] mutableCopy];
        for (PushMessage *message in array) {
            if([message.content rangeOfString:_searchBar.text].location != NSNotFound)
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
    [_searchBar endEditing:YES];
    [self searchDataFormLoc];
    [_tableView reloadData];
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
                    [self.navigationController showMessageTips:@"请选择圈子后再操作"];
                }
                [self.navigationController pushViewController:[RequestManagerController new] animated:YES];
            } else {
                [self.navigationController pushViewController:[BushManageViewController new] animated:YES];
            }
        } else if ([message.type isEqualToString:@"TASK"]) {//如果是任务
            //进入任务详情
            for (TaskModel *model in [_userManager getTaskArr:message.company_no]) {
                if(model.id == message.target_id.intValue) {
                    TaskDetailController *task = [TaskDetailController new];
                    task.data = model;
                    [self.navigationController pushViewController:task animated:YES];
                    break;
                }
            }
        } else if ([message.type isEqualToString:@"TASK_COMMENT_STATUS"]) {//如果是任务讨论信息变了
            for (TaskModel *model in [_userManager getTaskArr:message.company_no]) {
                if(model.id == message.target_id.intValue) {
                    TaskDetailController *task = [TaskDetailController new];
                    task.data = model;
                    [self.navigationController pushViewController:task animated:YES];
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
                tempTemp.rdate = @(message.addTime.timeIntervalSince1970 * 1000).stringValue;
                [self.navigationController pushControler:@"ComCalendarDetailViewController" parameters:@{@"calendar":tempTemp}];
            } else {
                Calendar *tempTemp = [sharedCalendar deepCopy];
                tempTemp.rdate = @(message.addTime.timeIntervalSince1970 * 1000).stringValue;
                [self.navigationController pushControler:@"RepCalendarDetailController" parameters:@{@"calendar":tempTemp}];
            }
        } else if ([message.type isEqualToString:@"CALENDARTIP"]) {//日程推送：
            NSArray<Calendar*> *calendarArr = [[UserManager manager] getCalendarArr];
            for (Calendar *temp in calendarArr) {
                if(message.target_id.intValue == temp.id) {
                    //展示详情
                    if(temp.repeat_type == 0) {
                        Calendar *tempTemp = [temp deepCopy];
                        tempTemp.rdate = @(message.addTime.timeIntervalSince1970 * 1000).stringValue;
                        [self.navigationController pushControler:@"ComCalendarDetailViewController" parameters:@{@"calendar":tempTemp}];
                    } else {
                        Calendar *tempTemp = [temp deepCopy];
                        tempTemp.rdate = @(message.addTime.timeIntervalSince1970 * 1000).stringValue;
                        [self.navigationController pushControler:@"RepCalendarDetailController" parameters:@{@"calendar":tempTemp}];
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
                    [self.navigationController pushViewController:task animated:YES];
                    break;
                }
            }
        }//网页
        else if ([message.type isEqualToString:@"REQUEST"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@request/details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%d",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        } else if ([message.type isEqualToString:@"APPROVAL"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Approval/Details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%d",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        } else if ([message.type isEqualToString:@"NEW_APPROVAL"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@ApprovalByFormBuilder/Details?id=%@&userGuid=%@&access_token=%@&from=message&companyNo=%d",XYFMobileDomain,message.target_id,_userManager.user.user_guid,_identityManager.identity.accessToken,message.company_no];
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        } else if([message.type isEqualToString:@"MAIL"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Mail/Details?id=%@&isSend=false&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        } else if([message.type isEqualToString:@"MEETING"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Meeting/Details?id=%@&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        } else if([message.type isEqualToString:@"VOTE"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@Vote/Details?id=%@&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        } else if([message.type isEqualToString:@"NOTICE"]){
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@NOTICE/Details?id=%@&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.navigationController pushViewController:webViewcontroller animated:YES];
        } else if ([message.type isEqualToString:@"WORK_ORDER"]) {
            WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
            webViewcontroller.applicationUrl = [NSString stringWithFormat:@"%@workorder/ClientDetails?id=%@&userGuid=%@&companyNo=%d&access_token=%@&from=message",XYFMobileDomain,message.target_id,_userManager.user.user_guid,message.company_no,_identityManager.identity.accessToken];
            [self.navigationController pushViewController:webViewcontroller animated:YES];
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
