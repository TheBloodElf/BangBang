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
#import "ComCalendarDetailViewController.h"
#import "RepCalendarDetailController.h"
#import "PushMessage.h"
#import "UserManager.h"
#import "IdentityManager.h"
#import "TaskDetailController.h"
#import "UserHttp.h"

@interface PushMessageController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;
    IdentityManager *_identityManager;
    UITableView *_tableView;//表格视图
    NSMutableArray<PushMessage*> *_pushMessageArr;//搜索视图的数据
    UIView *_noDataView;//没有数据的视图
    UISearchBar *_searchBar;//搜索视图
    RBQFetchedResultsController *_pushMessageFetchedResultsController;//推送消息数据监听
}

@end

@implementation PushMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    _userManager = [UserManager manager];
    _identityManager = [IdentityManager manager];
    _pushMessageFetchedResultsController = [_userManager createPushMessagesFetchedResultsController];
    _pushMessageFetchedResultsController.delegate = self;
    _pushMessageArr = [@[] mutableCopy];
    //创建搜素视图
    //创建搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    _searchBar.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:_searchBar];
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 55) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[UINib nibWithNibName:@"PushMessageCell" bundle:nil] forCellReuseIdentifier:@"PushMessageCell"];
    [self.view addSubview:_tableView];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClicked:)];
    _tableView.userInteractionEnabled = YES;
    [_tableView addGestureRecognizer:lpgr];
    //创建空太图
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.5 * (_tableView.frame.size.height - 10), _tableView.frame.size.width, 10)];
    label.text = @"没有更多数据";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [UIColor grayColor];
    _noDataView = [[UIView alloc] initWithFrame:_tableView.bounds];
    [_noDataView addSubview:label];
    //创建导航栏
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"标记" style:UIBarButtonItemStylePlain target:self action:@selector(biaojiClicked:)];
    [self searchDataFormLoc];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    _pushMessageArr = (id)controller.fetchedObjects;
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
        //从最后一个删除，这是有原因的
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
    if(_pushMessageArr.count == 0)
        _tableView.tableFooterView = _noDataView;
    else
        _tableView.tableFooterView = [UIView new];
    [_tableView reloadData];
}
#pragma mark -- 
#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar endEditing:YES];
    [self searchDataFormLoc];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_pushMessageArr[indexPath.row] contentHeight:MAIN_SCREEN_WIDTH - 113 font:12];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _pushMessageArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PushMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PushMessageCell" forIndexPath:indexPath];
    cell.data = _pushMessageArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView.editing == YES)
        return;
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        PushMessage *message = [_pushMessageArr[indexPath.row] deepCopy];
        if(message.unread == true) {
            message.unread = false;
            [_userManager updatePushMessage:message];
        }
        //分别进入对应的界面进行操作
        //如果是圈子操作
        if([message.type isEqualToString:@"COMPANY"]) {
            if([message.action isEqualToString:@"GENERAL"]) {
                [self.navigationController pushViewController:[RequestManagerController new] animated:YES];
            } else {
                [self.navigationController pushViewController:[BushManageViewController new] animated:YES];
            }
        } else if ([message.type isEqualToString:@"TASK"]) {//如果是任务
            //进入任务详情
            //获取任务详情 弹窗
            [UserHttp getTaskInfo:[message.target_id intValue] handler:^(id data, MError *error) {
                [self dismissTips];
                if(error) {
                    [self showFailureTips:error.statsMsg];
                    return ;
                }
                TaskModel *taskModel = [[TaskModel alloc] initWithJSONDictionary:data];
                taskModel.descriptionStr = data[@"description"];
                [_userManager upadteTask:taskModel];
                
                TaskDetailController *task = [TaskDetailController new];
                task.data = taskModel;
                [self.navigationController pushViewController:task animated:YES];
            }];
        } else if ([message.type isEqualToString:@"TASK_COMMENT_STATUS"]) {//如果是任务讨论信息变了
            for (TaskModel *model in [_userManager getTaskArr:message.company_no]) {
                if(model.id == message.target_id.intValue) {
                    TaskDetailController *task = [TaskDetailController new];
                    task.data = task;
                    [self.navigationController pushViewController:task animated:YES];
                    break;
                }
            }
        } else if ([message.type isEqualToString:@"CALENDARTIP"] || [message.type isEqualToString:@"CALENDAR"]) {//日程推送：日程分享
            NSArray<Calendar*> *calendarArr = [[UserManager manager] getCalendarArr];
            Calendar *calendar = nil;
            for (Calendar *temp in calendarArr) {
                if([message.target_id isEqualToString:temp.target_id]) {
                    calendar = temp;
                    break;
                }
            }
            if(calendar.repeat_type == 0) {
                ComCalendarDetailViewController *com = [ComCalendarDetailViewController new];
                com.data = calendar;
                [self.navigationController pushViewController:com animated:YES];
            } else {
                RepCalendarDetailController *com = [RepCalendarDetailController new];
                com.data = calendar;
                [self.navigationController pushViewController:com animated:YES];
            }
        } else if ([message.type isEqualToString:@"TASKTIP"]) {//任务提醒推送
            //进入任务详情
            for (TaskModel *model in [_userManager getTaskArr:message.company_no]) {
                if(model.id == message.target_id.intValue) {
                    TaskDetailController *task = [TaskDetailController new];
                    task.data = task;
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
