//
//  PushMessageController.m
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "PushMessageController.h"
#import "PushMessage.h"
#import "UserManager.h"
#import "IdentityManager.h"
#import "NoResultView.h"
#import "PushMessageCell.h"
#import "BushManageViewController.h"
#import "RequestManagerController.h"
#import "TaskDetailController.h"
#import "WebNonstandarViewController.h"
#import "ComCalendarDetailViewController.h"
#import "RepCalendarDetailController.h"

@interface PushMessageController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;
    IdentityManager *_identityManager;
    NSMutableArray<PushMessage*> *_pushMessageArr;//搜索视图的数据
    NoResultView *_noDataView;//没有数据的视图
    RBQFetchedResultsController *_pushMessageFetchedResultsController;//推送消息数据监听
    BOOL isFirstLoad;
}
@property (nonatomic, strong) UITableView *tableView;//表格视图
@property (nonatomic, strong) UISearchBar *searchBar;//搜索视图
@end

@implementation PushMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    self.view.backgroundColor = [UIColor whiteColor];
    //创建搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    _searchBar.tintColor = [UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1];
    [_searchBar setSearchBarBackgroundColor:[UIColor colorWithRed:247 / 255.f green:247 / 255.f blue:247 / 255.f alpha:1]];
    _searchBar.returnKeyType = UIReturnKeySearch;
    for(UIView * view in [_searchBar.subviews[0] subviews]) {
        if([view isKindOfClass:[UITextField class]]) {
            [(UITextField*)view setEnablesReturnKeyAutomatically:NO];
            break;
        }
    }
    [self.view addSubview:_searchBar];
    //创建空太图
    _noDataView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
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
    _userManager = [UserManager manager];
    _pushMessageFetchedResultsController = [_userManager createPushMessagesFetchedResultsController];
    _pushMessageFetchedResultsController.delegate = self;
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
    _noDataView = [[NoResultView alloc] initWithFrame:self.tableView.bounds];
    [self searchDataFormLoc];
    if(_pushMessageArr.count == 0)
        self.tableView.tableFooterView = _noDataView;
    else
        self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
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
            PushMessage *message = [[_tableView cellForRowAtIndexPath:indexPath] data];
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
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [self searchDataFormLoc];
    if(_pushMessageArr.count == 0)
        self.tableView.tableFooterView = _noDataView;
    else
        self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
}
//从本地搜索数据
- (void)searchDataFormLoc {
    NSMutableArray *array = [_userManager getPushMessageArr];
    if([NSString isBlank:self.searchBar.text])
        _pushMessageArr = array;
    else {
        NSMutableArray *currArr = [@[] mutableCopy];
        for (PushMessage *message in array) {
            if([message.content rangeOfString:self.searchBar.text].location != NSNotFound)
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
    [self.searchBar endEditing:YES];
    [self searchDataFormLoc];
    if(_pushMessageArr.count == 0)
        self.tableView.tableFooterView = _noDataView;
    else
        self.tableView.tableFooterView = [UIView new];
    [self.tableView reloadData];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([NSString isBlank:[_pushMessageArr[indexPath.row] content]])
        return [@"会议有新的消息" textSizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 113, 10000)].height + 45;
    return [[_pushMessageArr[indexPath.row] content] textSizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 113, 10000)].height + 45;
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
        message.unread = NO;
        [_userManager updatePushMessage:message];
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
            Calendar *sharedCalendar = [Calendar new];
            [sharedCalendar mj_setKeyValues:calendarDic];
            sharedCalendar.descriptionStr = calendarDic[@"description"];
            //展示详情
            if(sharedCalendar.repeat_type == 0) {
                Calendar *tempTemp = [sharedCalendar deepCopy];
                tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                ComCalendarDetailViewController *vc = [ComCalendarDetailViewController new];
                vc.data = tempTemp;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                Calendar *tempTemp = [sharedCalendar deepCopy];
                tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                RepCalendarDetailController *vc = [RepCalendarDetailController new];
                vc.data = tempTemp;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else if ([message.type isEqualToString:@"CALENDARTIP"]) {//日程推送：
            NSArray<Calendar*> *calendarArr = [[UserManager manager] getCalendarArr];
            for (Calendar *temp in calendarArr) {
                //去掉删除的
                if(temp.status == 0) continue;
                if(message.target_id.intValue == temp.id) {
                    //展示详情
                    if(temp.repeat_type == 0) {
                        Calendar *tempTemp = [temp deepCopy];
                        tempTemp.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                        ComCalendarDetailViewController *vc = [ComCalendarDetailViewController new];
                        vc.data = tempTemp;
                        [self.navigationController pushViewController:vc animated:YES];
                    } else {
                        //判断是否已经删除
                        if([temp haveDeleteDate:message.addTime]) {
                            [self.navigationController.view showMessageTips:@"当次日程已被删除！"];
                            return;
                        }
                        Calendar *tempCalendar = [temp deepCopy];
                        //判断是否是完成
                        if (tempCalendar.status == 2 || [tempCalendar haveFinishDate:message.addTime]) {
                            tempCalendar.status = 2;
                        } else {
                            tempCalendar.rdate = @(message.addTime.timeIntervalSince1970).stringValue;
                        }
                        //显示
                        RepCalendarDetailController *vc = [RepCalendarDetailController new];
                        vc.data = tempCalendar;
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                    //找到一个对应的就结束函数
                    return;
                }
            }
            //如果没有找到对应的，就提示已经被删除
            [self.navigationController.view showMessageTips:@"该日程已被删除！"];
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
