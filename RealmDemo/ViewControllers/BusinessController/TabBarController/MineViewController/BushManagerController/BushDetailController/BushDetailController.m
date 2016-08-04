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
#import "UserHttp.h"
#import "UpdateBushController.h"
#import "SingleSelectController.h"

@interface BushDetailController ()<SingleSelectDelegate> {
    Company *_currCompany;//当前圈子
    UserManager *_userManager;//用户管理器
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
    //操作按钮应该显示什么内容
    self.opertionBtn.hidden = NO;
    Employee *ownerInThisCompany = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_currCompany.company_no];
    self.opertionBtn.hidden = YES;
    //如果自己在这个圈子中，说明可以进行如下操作
    if(ownerInThisCompany.id != 0) {
        self.opertionBtn.hidden = NO;
        //如果是圈子的创建者 就可以修改和转让
        if([_userManager.user.user_guid isEqualToString:_currCompany.admin_user_guid]) {
            [self.opertionBtn setTitle:@"转让圈子" forState:UIControlStateNormal];
            [self.opertionBtn addTarget:self action:@selector(transCompanyClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(updateCompanyInfo:)];
        } else {
            //如果正在申请离职或者正在申请加入 就不添加按钮
            if(ownerInThisCompany.status == 0 || ownerInThisCompany.status == 4 ||ownerInThisCompany.status == 2)  {
                self.opertionBtn.hidden = YES;
            } else {//只能退出圈子
                [self.opertionBtn setTitle:@"退出圈子" forState:UIControlStateNormal];
                [self.opertionBtn addTarget:self action:@selector(exitCompanyClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
     //用圈主信息来填充内容
    [UserHttp getCompanyOwner:_currCompany.company_no handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view showFailureTips:@"圈主信息获取失败,请重新进入此页面获取"];
            return ;
        }
        self.companyOwer.text = data[@"real_name"];
        self.companyOwerPhone.text = data[@"email"];
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.companyAvater sd_setImageWithURL:[NSURL URLWithString:_currCompany.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.companyName.text = _currCompany.company_name;
    self.companyType.text = [_currCompany companyTypeStr];
}
- (void)dataDidChange {
    _currCompany = [self.data deepCopy];
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
    SingleSelectController *select = [SingleSelectController new];
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_currCompany.company_no];
    select.outEmployees = [@[employee] mutableCopy];
    select.companyNo = _currCompany.company_no;
    select.delegate = self;
    [self.navigationController pushViewController:select animated:YES];
}
#pragma mark --
#pragma mark -- SingleSelectDelegate
- (void)singleSelect:(Employee *)employee {
    [self.navigationController.view showLoadingTips:@"请稍等..."];
    Employee *ownerInThisCompany = [[_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_currCompany.company_no] deepCopy];
    [UserHttp transCompany:_currCompany.company_no ownerGuid:ownerInThisCompany.user_guid toGuid:employee.user_guid handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        [self.navigationController.view showSuccessTips:@"转让已发出，请等待"];
        _currCompany.admin_user_guid = employee.user_guid;
        [_userManager updateCompany:_currCompany];
        ownerInThisCompany.status = 1;
        [_userManager updateEmployee:ownerInThisCompany];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
//退出圈子
- (void)exitCompanyClicked:(UIButton*)btn {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"圈子名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入名称...";
        textField.text = [NSString stringWithFormat:@"我是%@，请求退出圈子",_userManager.user.real_name];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *field = alertVC.textFields[0];
        if([NSString isBlank:field.text]) {
            field.text = [NSString stringWithFormat:@"我是%@，请求退出圈子",_userManager.user.real_name];
        }
        [self.navigationController.view showLoadingTips:@"请稍等..."];
        Employee *currEmployee = [[_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_currCompany.company_no] deepCopy];
        [UserHttp updateEmployeeStatus:currEmployee.employee_guid status:4 reason:field.text handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            currEmployee.status = 4;
            [_userManager updateEmployee:currEmployee];
            [self.navigationController.view showSuccessTips:@"请求已发出，请等待"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    UIAlertAction *cancleActio = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:cancleActio];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
