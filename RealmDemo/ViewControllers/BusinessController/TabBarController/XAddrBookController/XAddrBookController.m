//
//  XAddrBookController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "XAddrBookController.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "XAddrBookCell.h"
#import "MoreSelectView.h"
#import "InviteColleagueController.h"
#import "MineInfoEditController.h"
#import "RYChatController.h"
#import "RequestManagerController.h"
#import "DiscussListViewController.h"

@interface XAddrBookController ()<RBQFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,MoreSelectViewDelegate> {
    UITableView *_tableView;//展示数据的表格视图
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据监听
    RBQFetchedResultsController *_employeeFetchedResultsController;//员工数据监听
    
    NSMutableArray<Employee*> *_employeeArr;//当前圈子员工数组
    NSMutableArray *_employeekeyArr;//都有的首字母数组
    NSMutableArray *_employeeDataArr;//所有的值数组
    MoreSelectView *_moreSelectView;//多选视图
}

@end

@implementation XAddrBookController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"联系人";
    _employeeArr = [@[] mutableCopy];
    _employeekeyArr = [@[] mutableCopy];
    _employeeDataArr = [@[] mutableCopy];
    _userManager = [UserManager manager];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    _employeeFetchedResultsController = [_userManager createEmployeesFetchedResultsControllerWithCompanyNo:_userManager.user.currCompany.company_no];
    _employeeFetchedResultsController.delegate = self;
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT- 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [self tableViewHeaderView];
    _tableView.tableFooterView = [UIView new];
    //自动计算CELL高度
//    _tableView.estimatedRowHeight = 68.0;
//    _tableView.rowHeight = UITableViewAutomaticDimension;
    [_tableView registerNib:[UINib nibWithNibName:@"XAddrBookCell" bundle:nil] forCellReuseIdentifier:@"XAddrBookCell"];
    [self.view addSubview:_tableView];
    //创建选择视图
    //是不是当前圈子的管理员
    if([_userManager.user.currCompany.admin_user_guid isEqualToString:_userManager.user.user_guid]) {
        _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 15, 0, 100, 120)];
        _moreSelectView.selectArr = @[@"发起群聊",@"邀请同事",@"申请管理"];
    }
    else {
        _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 15, 0, 100, 80)];
        _moreSelectView.selectArr = @[@"发起群聊",@"邀请同事"];
    }
    _moreSelectView.delegate = self;
    [_moreSelectView setupUI];
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
    //创建导航按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(leftClicked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigationbar_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(rightClicked:)];
    //从本地读取一次信息
    if(_userManager.user.currCompany.company_no) {
        _employeeArr = [_userManager getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no status:5];
        [self sortEmployee];
    }
    [_tableView reloadData];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor homeListColor];
}
- (void)leftClicked:(UIBarButtonItem*)item {
    if(_userManager.user.currCompany.company_no == 0) {
        _employeeArr = [@[] mutableCopy];
        [_tableView reloadData];
    } else {
        [self.navigationController.view showLoadingTips:@""];
        //从网络上获取最新的员工数据
        [UserHttp getEmployeeCompnyNo:_userManager.user.currCompany.company_no status:5 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            NSMutableArray *array = [@[] mutableCopy];
            for (NSDictionary *dic in data[@"list"]) {
                Employee *employee = [[Employee alloc] initWithJSONDictionary:dic];
                [array addObject:employee];
            }
            [UserHttp getEmployeeCompnyNo:_userManager.user.currCompany.company_no status:0 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
                [self.navigationController.view dismissTips];
                if(error) {
                    [self.navigationController.view showFailureTips:error.statsMsg];
                    return ;
                }
                for (NSDictionary *dic in data[@"list"]) {
                    Employee *employee = [[Employee alloc] initWithJSONDictionary:dic];
                    [array addObject:employee];
                }
                //存入本地数据库
                [_userManager updateEmployee:array companyNo:_userManager.user.currCompany.company_no];
            }];
        }];
    }
}
- (void)rightClicked:(UIBarButtonItem*)item {
    if(_moreSelectView.isHide)
        [_moreSelectView showSelectView];
    else
        [_moreSelectView hideSelectView];
}
#pragma mark -- 
#pragma mark -- MoreSelectViewDelegate
- (void)moreSelectIndex:(int)index {
    if(index == 0) {
        //群聊
        RYChatController *temp = [[RYChatController alloc]init];
        temp.targetId = @(_userManager.user.currCompany.company_no).stringValue;
        temp.conversationType = ConversationType_GROUP;
        temp.title = _userManager.user.currCompany.company_name;
        temp.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:temp animated:YES];
    } else if(index == 1) {
        //邀请
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"InviteColleagueController" bundle:nil];
        InviteColleagueController *colleague = [story instantiateViewControllerWithIdentifier:@"InviteColleagueController"];
        colleague.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:colleague animated:YES];
    } else {
        RequestManagerController *request = [RequestManagerController new];
        request.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:request animated:YES];
    }
}
- (UIView*)tableViewHeaderView {
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    view.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 60);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 50, 50)];
    [imageView zy_cornerRadiusRoundingRect];
    imageView.image = [UIImage imageNamed:@"discussion_portrait"];
    [view addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(75, 21, MAIN_SCREEN_WIDTH - 85, 17)];
    label.text = @"讨论组";
    [view addSubview:label];
    [view addTarget:self action:@selector(discussClicked:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}
- (void)discussClicked:(UIButton*)btn {
    DiscussListViewController *list = [DiscussListViewController new];
    list.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:list animated:YES];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if(controller == _employeeFetchedResultsController) {
        if(_userManager.user.currCompany.company_no) {
            _employeeArr = [_userManager getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no status:5];
            [self sortEmployee];
        }
        [_tableView reloadData];
    } else {
        if(_userManager.user.currCompany.company_no) {
            _employeeArr = [_userManager getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no status:5];
            [self sortEmployee];
        }
        [_tableView reloadData];
        //创建选择视图
        [_moreSelectView removeFromSuperview];
        //是不是当前圈子的管理员
        if([_userManager.user.currCompany.admin_user_guid isEqualToString:_userManager.user.user_guid]) {
            _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 15, 0, 100, 120)];
            _moreSelectView.selectArr = @[@"发起群聊",@"邀请同事",@"申请管理"];
        }
        else {
            _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 15, 0, 100, 80)];
            _moreSelectView.selectArr = @[@"发起群聊",@"邀请同事"];
        }
        _moreSelectView.delegate = self;
        [_moreSelectView setupUI];
        [self.view addSubview:_moreSelectView];
        [self.view bringSubviewToFront:_moreSelectView];
        _employeeFetchedResultsController = [_userManager createEmployeesFetchedResultsControllerWithCompanyNo:_userManager.user.currCompany.company_no];
        _employeeFetchedResultsController.delegate = self;
    }
}
//对员工数组进行排序
- (void)sortEmployee {
    NSMutableDictionary<NSString*,NSMutableArray*> *_currDataArr = [@{} mutableCopy];//根据搜索出的员工的首字母-员工数组的字典
    NSMutableArray *dataArr = [@[] mutableCopy];
    NSMutableArray *keyArr = [@[] mutableCopy];
    //先把字典填充A-Z对应的空数组
    for (int i = 0;i < 26;i ++) {
        char currChar = 'A' + i;
        NSString *currStr = [NSString stringWithFormat:@"%c",currChar];
        [_currDataArr setObject:[@[] mutableCopy] forKey:currStr];
    }
    [_currDataArr setObject:[@[] mutableCopy] forKey:@"#"];
    //填充数据
    for (Employee *tempEmployee in _employeeArr) {
        NSString *firstChar = [tempEmployee.user_real_name firstChar];
        NSMutableArray *currArr = _currDataArr[firstChar];
        [currArr addObject:tempEmployee];
        _currDataArr[firstChar] = currArr;
    }
    //清除掉没有值的键值对
    for (NSString *currStr in _currDataArr.allKeys) {
        if(_currDataArr[currStr].count == 0) {
            [_currDataArr removeObjectForKey:currStr];
        }
    }
    //把key按照ABCDEFG...排序  分成两个数组装
    keyArr = [_currDataArr.allKeys mutableCopy];
    [keyArr sortUsingComparator:^NSComparisonResult(NSString* obj1,NSString* obj2) {
        return [obj1 compare:obj2] == 1;
    }];
    //把#放最后
    if(keyArr.count != 0) {
        if([keyArr[0] isEqualToString:@"#"]) {
            [keyArr removeObject:@"#"];
            [keyArr addObject:@"#"];
        }
    }
    //得到对应的名字数组
    for (NSString *keyStr in keyArr) {
        [dataArr addObject:_currDataArr[keyStr]];
    }
    _employeeDataArr = dataArr;
    _employeekeyArr = keyArr;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)sender heightForHeaderInSection:(NSInteger)section {
    return 20.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (UIView*)tableView:(UITableView *)sender viewForHeaderInSection:(NSInteger)section {
    UIImageView *bkgImageView = [[UIImageView alloc] init];
    bkgImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *tLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 120, 14)];
    tLabel.textColor=[UIColor blackColor];
    tLabel.backgroundColor = [UIColor clearColor];
    tLabel.font = [UIFont systemFontOfSize:14];
    tLabel.text = _employeekeyArr[section];
    [bkgImageView addSubview:tLabel];
    return bkgImageView;
}

- (NSInteger)tableView:(UITableView *)sender numberOfRowsInSection:(NSInteger)section {
    return [_employeeDataArr[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _employeekeyArr.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)sender {
    return _employeekeyArr;
}
//将要显示的时候使用
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    //分割线长度 距离
//    UIEdgeInsets edgeInset = UIEdgeInsetsZero;
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
//        [cell setSeparatorInset:edgeInset];
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
//        [cell setLayoutMargins:edgeInset];
//}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XAddrBookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XAddrBookCell" forIndexPath:indexPath];
    Employee * employee = [[_employeeDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.data = employee;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Employee * employee = [[_employeeDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([employee.user_guid isEqualToString:_userManager.user.user_guid]) {
        MineInfoEditController *vc = [MineInfoEditController new];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        //单聊
        RYChatController *conversationVC = [[RYChatController alloc]init];
        conversationVC.conversationType =ConversationType_PRIVATE; //会话类型，这里设置为 PRIVATE 即发起单聊会话。
        conversationVC.targetId = @(employee.user_no).stringValue; // 接收者的 targetId，这里为举例。
        conversationVC.friends = employee;
        conversationVC.title = employee.user_real_name; // 会话的 title。
        conversationVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:conversationVC animated:YES];
    }
}
@end
