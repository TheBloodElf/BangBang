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

@interface XAddrBookController ()<RBQFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,MoreSelectViewDelegate> {
    UITableView *_tableView;//展示数据的表格视图
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据监听
    
    NSMutableArray<Employee*> *_employeeArr;//当前圈子员工数组
    NSMutableArray *_employeekeyArr;//都有的首字母数组
    NSMutableArray *_employeeDataArr;//所有的值数组
    MoreSelectView *_moreSelectView;//多选视图
}

@end

@implementation XAddrBookController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"讨论组";
    _employeeArr = [@[] mutableCopy];
    _employeekeyArr = [@[] mutableCopy];
    _employeeDataArr = [@[] mutableCopy];
    _userManager = [UserManager manager];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT- 44) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [self tableViewHeaderView];
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"XAddrBookCell" bundle:nil] forCellReuseIdentifier:@"XAddrBookCell"];
    [self.view addSubview:_tableView];
    //先从本地获取一次信息
    if(_userManager.user.currCompany)
        [self getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no];
    else
        [self getEmployeeWithCompanyNo:0];
    //创建选择视图
    //是不是当前圈子的管理员
    if([_userManager.user.currCompany.admin_user_guid isEqualToString:_userManager.user.user_guid]) {
        _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 15, 64, 100, 120)];
        _moreSelectView.selectArr = @[@"发起群聊",@"邀请同事",@"申请管理"];
    }
    else {
        _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 15, 64, 100, 80)];
        _moreSelectView.selectArr = @[@"发起群聊",@"邀请同事"];
    }
    _moreSelectView.delegate = self;
    [_moreSelectView setupUI];
    [self.view addSubview:_moreSelectView];
    [self.view bringSubviewToFront:_moreSelectView];
    //创建导航按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(leftClicked:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.frostedViewController.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)leftClicked:(UIBarButtonItem*)item {
    //先从本地获取一次信息
    if(_userManager.user.currCompany)
        [self getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no];
    else
        [self getEmployeeWithCompanyNo:0];
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
    } else {
        //邀请
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"InviteColleagueController" bundle:nil];
        InviteColleagueController *colleague = [story instantiateViewControllerWithIdentifier:@"InviteColleagueController"];
        colleague.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:colleague animated:YES];
    }
}
- (UIView*)tableViewHeaderView {
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    view.frame = CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 60);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 50, 50)];
    imageView.image = [UIImage imageNamed:@"discussion_portrait"];
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = 25.f;
    [view addSubview:imageView];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(75, 21, MAIN_SCREEN_WIDTH - 85, 17)];
    label.text = @"讨论组";
    [view addSubview:label];
    [view addTarget:self action:@selector(discussClicked:) forControlEvents:UIControlEventTouchUpInside];
    return view;
}
- (void)discussClicked:(UIButton*)btn {
    
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    User *user = controller.fetchedObjects[0];
    if(user.currCompany)
        [self getEmployeeWithCompanyNo:user.currCompany.company_no];
    else
        [self getEmployeeWithCompanyNo:0];
}
//根据圈子ID填充员工数组
- (void)getEmployeeWithCompanyNo:(int)companyNo {
    if(companyNo == 0) {
        _employeeArr = [@[] mutableCopy];
        [self sortEmployee];
        [_tableView reloadData];
    } else {
        //从本地加载数据，如果没有数据就转菊花
        _employeeArr = [_userManager getEmployeeWithCompanyNo:companyNo status:1];
        [self sortEmployee];
        [_tableView reloadData];
        //从网络上获取最新的员工数据
        if(_employeeArr.count == 0)
            [self.navigationController.view showLoadingTips:@"请稍等..."];
        [UserHttp getEmployeeCompnyNo:companyNo status:5 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:@"获取失败，请重试"];
                return ;
            }
            NSMutableArray *array = [@[] mutableCopy];
            for (NSDictionary *dic in data[@"list"]) {
                Employee *employee = [Employee new];
                [employee mj_setKeyValues:[dic mj_keyValues]];
                [array addObject:employee];
            }
            //存入本地数据库
            [_userManager updateEmployee:array companyNo:companyNo];
            _employeeArr = array;
            [self sortEmployee];
            [_tableView reloadData];
        }];
    }
}
//对员工数组进行排序
- (void)sortEmployee {
    NSMutableDictionary<NSString*,NSMutableArray*> *_currDataArr = [@{} mutableCopy];//根据搜索出的员工的首字母-员工数组的字典
    [_employeeDataArr removeAllObjects];
    [_employeekeyArr removeAllObjects];
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
    _employeekeyArr = [_currDataArr.allKeys mutableCopy];
    [_employeekeyArr sortUsingComparator:^NSComparisonResult(NSString* obj1,NSString* obj2) {
        return [obj1 compare:obj2] == 1;
    }];
    //把#放最后
    if(_employeekeyArr.count != 0) {
        if([_employeekeyArr[0] isEqualToString:@"#"]) {
            [_employeekeyArr removeObject:@"#"];
            [_employeekeyArr addObject:@"#"];
        }
    }
    //得到对应的名字数组
    for (NSString *keyStr in _employeekeyArr) {
        [_employeeDataArr addObject:_currDataArr[keyStr]];
    }
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

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XAddrBookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XAddrBookCell" forIndexPath:indexPath];
    Employee * employee = [[_employeeDataArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.data = employee;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
