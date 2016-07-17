//
//  PushMessageController.m
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "PushMessageController.h"
#import "PushMessageCell.h"
#import "PushMessage.h"
#import "UserManager.h"

@interface PushMessageController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;
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
    _pushMessageFetchedResultsController = [_userManager createPushMessagesFetchedResultsController];
    _pushMessageFetchedResultsController.delegate = self;
    _pushMessageArr = [@[] mutableCopy];
    //创建搜素视图
    //创建搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, MAIN_SCREEN_WIDTH, 55)];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"搜索";
    _searchBar.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:_searchBar];
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + 55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64 - 55) style:UITableViewStylePlain];
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
            PushMessage *temp = [PushMessage copyFromPushMessage:pushMessage];
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
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    [self searchDataFormLoc];
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
    if(tableView.editing == NO)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    else {
        if(_pushMessageArr[indexPath.row].unread == YES) {
            PushMessage *message = [PushMessage copyFromPushMessage:_pushMessageArr[indexPath.row]];
            message.unread = NO;
            [_userManager updatePushMessage:message];
        }
        //分别进入对应的界面进行操作
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
