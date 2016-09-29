//
//  SearchEmployeeController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/9/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SearchEmployeeController.h"
#import "NoResultView.h"
#import "UserManager.h"
#import "XAddrBookCell.h"
#import "RYChatController.h"
#import "MineInfoEditController.h"

@interface SearchEmployeeController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate> {
    NoResultView *_noDataView;//没有数据的视图
    UserManager *_userManager;
    NSMutableArray<Employee*> *_employeeArr;//搜索视图的数据
}
@property (nonatomic, strong) UITableView *tableView;//表格视图
@property (nonatomic, strong) UISearchBar *searchBar;//搜索视图

@end

@implementation SearchEmployeeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"搜索联系人";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
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
    
    //创建表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 55, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 55 - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableView registerNib:[UINib nibWithNibName:@"XAddrBookCell" bundle:nil] forCellReuseIdentifier:@"XAddrBookCell"];
    [self.view addSubview:_tableView];
    _noDataView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    [self searchFormLoc];
}
- (void)searchFormLoc {
    NSArray<Employee*> *employeeArr = [_userManager getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no status:5];
    if([NSString isBlank:_searchBar.text]) {
        _employeeArr = [employeeArr mutableCopy];
        if(_employeeArr.count)
            _tableView.tableFooterView = [UIView new];
        else
            _tableView.tableFooterView = _noDataView;
        [_tableView reloadData];
        return;
    }
    NSMutableArray *array = [@[] mutableCopy];
    for (Employee *employee in employeeArr) {
        if([employee.real_name rangeOfString:_searchBar.text].location != NSNotFound)
            [array addObject:employee];
    }
    _employeeArr = [array mutableCopy];
    if(_employeeArr.count)
        _tableView.tableFooterView = [UIView new];
    else
        _tableView.tableFooterView = _noDataView;
    [_tableView reloadData];
}
#pragma mark -- UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    [self searchFormLoc];
}
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _employeeArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XAddrBookCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XAddrBookCell" forIndexPath:indexPath];
    cell.data = _employeeArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Employee * employee = _employeeArr[indexPath.row];
    if ([employee.user_guid isEqualToString:_userManager.user.user_guid]) {
        MineInfoEditController *vc = [MineInfoEditController new];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        //单聊
        RYChatController *conversationVC = [[RYChatController alloc]init];
        conversationVC.conversationType =ConversationType_PRIVATE; //会话类型，这里设置为 PRIVATE 即发起单聊会话。
        conversationVC.targetId = @(employee.user_no).stringValue; // 接收者的 targetId，这里为举例。
        conversationVC.title = employee.user_real_name; // 会话的 title。
        conversationVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:conversationVC animated:YES];
    }
}

@end
