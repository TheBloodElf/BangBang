//
//  SelectCompanyController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SelectCompanyController.h"
#import "UserInfo.h"
#import "UtikIesTool.h"
#import "CompanyModel.h"
#import "Identity.h"
#import "ShareModel.h"
#import "SelectCompanyCell.h"
#import "ShareContentController.h"
#import "ShareModel.h"
@interface SelectCompanyController ()<UITableViewDelegate,UITableViewDataSource>
{
    UserInfo *user;
    UITableView *_tableView;
    NSMutableArray<CompanyModel*> *_modelArr;
}
@end

@implementation SelectCompanyController

- (void)viewDidLoad {
    [super viewDidLoad];
    _modelArr = [@[] mutableCopy];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 250, 330) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"SelectCompanyCell" bundle:nil] forCellReuseIdentifier:@"SelectCompanyCell"];
    [self.view addSubview:_tableView];
    self.title = @"选择圈子";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftAction:)];
    //应用组间共享数据
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.lottak.bangbang"];
    NSData *userData = [sharedDefaults valueForKey:@"GroupUserInfo"];
    user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    [ShareModel shareInstance].shareUserGuid = user.user_guid;
    //应用组间共享数据
    NSUserDefaults *sharedDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.lottak.bangbang"];
    NSString *accToken = [[sharedDefault valueForKey:@"GroupIdentityInfo"] accessToken];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    NSDictionary *parameters = @{@"user_guid":user.user_guid,@"access_token":accToken};
    [self.navigationController.view showLoadingTips:@""];
    [manager GET:@"Companies/user_companies" parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self.navigationController.view dismissTips];
        for (NSDictionary *dic in responseObject[@"data"]) {
            CompanyModel *model = [CompanyModel new];
            model.company_no = dic[@"company_no"];
            model.admin_user_guid = dic[@"admin_user_guid"];
            model.company_name = dic[@"company_name"];
            model.company_type = dic[@"company_type"];
            model.logo = dic[@"logo"];
            [_modelArr addObject:model];
        }
        [_tableView reloadData];
        if([self getSelectCompanyNum] == 0)
            self.navigationItem.rightBarButtonItem.enabled = NO;
        else
            self.navigationItem.rightBarButtonItem.enabled = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.navigationController.view dismissTips];
    }];
    self.automaticallyAdjustsScrollViewInsets = YES;
    // Do any additional setup after loading the view.
}
- (void)rightAction:(UIBarButtonItem*)item
{
    [ShareModel shareInstance].shareCompanyNo = [self getSelectCompanyNoArr];
    ShareContentController *share = [ShareContentController new];
    [self.navigationController pushViewController:share animated:YES];
}
- (void)leftAction:(UIBarButtonItem*)item
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (NSString*)getSelectCompanyNoArr
{
    NSMutableArray *array = [@[] mutableCopy];
    for (CompanyModel *model in _modelArr) {
        if(model.isSelected == YES)
            [array addObject:model.company_no];
    }
    return [array componentsJoinedByString:@","];
}
- (NSInteger)getSelectCompanyNum
{
    NSInteger count = 0;
    for (CompanyModel *model in _modelArr) {
        if(model.isSelected == YES)
            count ++;
    }
    return count;
}
#pragma mark --
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _modelArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectCompanyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectCompanyCell" forIndexPath:indexPath];
    [cell setModel:_modelArr[indexPath.row]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _modelArr[indexPath.row].isSelected = !_modelArr[indexPath.row].isSelected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if([self getSelectCompanyNum] == 0)
        self.navigationItem.rightBarButtonItem.enabled = NO;
    else
        self.navigationItem.rightBarButtonItem.enabled = YES;
}
#pragma mark --
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}
@end
