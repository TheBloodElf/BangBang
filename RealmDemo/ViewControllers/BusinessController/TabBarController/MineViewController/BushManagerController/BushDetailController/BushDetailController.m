//
//  BushDetailController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/14.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "BushDetailController.h"
#import "Company.h"
#import "UserManager.h"
#import "UpdateBushController.h"

@interface BushDetailController () {
    Company *_currCompany;//当前圈子
    UserManager *_userManager;//用户管理器
    Employee *_currCompanyOwner;//当前圈子的创建者
}
@property (strong, nonatomic) UIImageView *companyAvater;
@property (weak, nonatomic) IBOutlet UILabel *companyName;
@property (weak, nonatomic) IBOutlet UILabel *companyType;
@property (weak, nonatomic) IBOutlet UILabel *companyOwer;
@property (weak, nonatomic) IBOutlet UILabel *companyOwerPhone;
@property (weak, nonatomic) IBOutlet UIButton *opertionBtn;
@end

@implementation BushDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"圈子详情";
    self.tableView.tableFooterView = [UIView new];
    self.companyAvater = [[UIImageView alloc] initWithFrame:CGRectMake(10, 170, 60, 60)];
    self.companyAvater.layer.cornerRadius = 30.f;
    self.companyAvater.clipsToBounds = YES;
    [self.tableView addSubview:self.companyAvater];
    _userManager = [UserManager manager];
    //得到圈子创建者信息
    
}
- (void)dataDidChange {
    _currCompany = self.data;
}
//每次进来都填充一次 万一修改了就好实时更新
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.companyAvater sd_setImageWithURL:[NSURL URLWithString:_currCompany.logo] placeholderImage:[UIImage imageNamed:@""]];
    self.companyName.text = _currCompany.company_name;
    self.companyType.text = [_currCompany companyTypeStr];
    //用圈主信息来填充内容
    self.companyOwer.text = _currCompanyOwner.real_name;
    self.companyOwerPhone.text = _currCompanyOwner.email;
    //操作按钮应该显示什么内容
    self.opertionBtn.hidden = NO;
    //如果是圈子的创建者 就可以修改和转让
    if([_userManager.user.user_guid isEqualToString:_currCompany.admin_user_guid]) {
        [self.opertionBtn setTitle:@"转让圈子" forState:UIControlStateNormal];
        [self.opertionBtn addTarget:self action:@selector(transCompanyClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(updateCompanyInfo:)];
    } else {//只能退出圈子
        [self.opertionBtn setTitle:@"退出圈子" forState:UIControlStateNormal];
        [self.opertionBtn addTarget:self action:@selector(exitCompanyClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}
//修改圈子信息
- (void)updateCompanyInfo:(UIBarButtonItem*)item {
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MineView" bundle:nil];
    UpdateBushController *bush = [story instantiateViewControllerWithIdentifier:@"UpdateBushController"];
    bush.data = _currCompany;
    [self.navigationController pushViewController:bush animated:YES];
}
//转让圈子
- (void)transCompanyClicked:(UIButton*)btn {
    
}
//退出圈子
- (void)exitCompanyClicked:(UIButton*)btn {
    
}
@end
