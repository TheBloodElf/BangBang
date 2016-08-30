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

#import "PushMessageOpertion.h"

@interface PushMessageController () {
    UserManager *_userManager;
    RBQFetchedResultsController *_pushMessageFetchedResultsController;//推送消息数据监听
    BOOL isFirstLoad;
    
    PushMessageOpertion *_pushMessageOpertion;
}

@end

@implementation PushMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    _pushMessageOpertion = [PushMessageOpertion new];
    //创建搜索框
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 55)];
    _searchBar.delegate = _pushMessageOpertion;
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

    _pushMessageFetchedResultsController = [_userManager createPushMessagesFetchedResultsController];
    _pushMessageFetchedResultsController.delegate = _pushMessageOpertion;
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 55 - 64) style:UITableViewStylePlain];
    _tableView.delegate = _pushMessageOpertion;
    _tableView.dataSource = _pushMessageOpertion;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[UINib nibWithNibName:@"PushMessageCell" bundle:nil] forCellReuseIdentifier:@"PushMessageCell"];
    [self.view addSubview:_tableView];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClicked:)];
    _tableView.userInteractionEnabled = YES;
    [_tableView addGestureRecognizer:lpgr];
    
    _pushMessageOpertion.pushMessageController = self;
    [_pushMessageOpertion startConnect];
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

@end
