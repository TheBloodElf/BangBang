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
    [NSKeyedUnarchiver setClass:[UserInfo class] forClassName:@"UserInfo"];
    user = [NSKeyedUnarchiver unarchiveObjectWithData:userData];
    [ShareModel shareInstance].shareUserGuid = user.user_guid;
    //应用组间共享数据
    NSUserDefaults *sharedDefault = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.lottak.bangbang"];
    NSData *identityDate = [sharedDefault valueForKey:@"GroupIdentityInfo"];
    [NSKeyedUnarchiver setClass:[Identity class] forClassName:@"Identity"];
    Identity *identity = [NSKeyedUnarchiver unarchiveObjectWithData:identityDate];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:KBSSDKAPIDomain]];
    [manager setSecurityPolicy:[self customSecurityPolicy]];
    NSDictionary *parameters = @{@"user_guid":user.user_guid,@"access_token":identity.accessToken};
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
- (AFSecurityPolicy *)customSecurityPolicy
{
    //先导入证书，找到证书的路径
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"bangbangssl" ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    //AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    NSSet *set = [[NSSet alloc] initWithObjects:certData, nil];
    securityPolicy.pinnedCertificates = set;
    return securityPolicy;
}

@end
