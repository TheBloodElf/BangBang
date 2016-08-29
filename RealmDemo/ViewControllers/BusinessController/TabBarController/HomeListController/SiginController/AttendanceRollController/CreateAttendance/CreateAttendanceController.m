//
//  CreateAttendanceController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/21.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "CreateAttendanceController.h"
#import "SiginName.h"
#import "PunchCardRemind.h"
#import "WorkAdressCell.h"
#import "PalneTableViewCell.h"
#import "SiginRuleSet.h"
#import "PunchCardAddressSetting.h"
#import "SelectAttendanceWorkDay.h"
#import "SelectAttendanceRange.h"
#import "SelectAttendanceSpaceTime.h"
#import "SelectAttendanceTime.h"
#import "SelectAdressController.h"

#import "UserManager.h"
#import "UserHttp.h"

@interface CreateAttendanceController ()<UITableViewDelegate,UITableViewDataSource,PunchCardRemindDelegate,WorkAdressCellDelegate,SelectAttendanceWorkDayDelegate,SelectAttendanceRangeDelegate,SelectAdressDelegate>
{
    UserManager *_userManager;//用户管理器
    UITableView  *_tableView;//展示数据的表格视图
    SiginRuleSet *_currSiginRule;//签到规则模型
    NSDictionary *_workDic;//数字日期映射关系
}

@end

@implementation CreateAttendanceController

#pragma mark --
#pragma mark -- LifeStyle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建考勤";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    //初始化数据
    _currSiginRule = [SiginRuleSet new];
    _currSiginRule.json_list_address_settings = [@[] mutableCopy];
    _currSiginRule.work_day = @"1,2,3,4,5";
    _currSiginRule.start_work_time_alert = 5;
    _currSiginRule.end_work_time_alert = 5;
    _currSiginRule.start_work_time = [[NSDate date] timeIntervalSince1970] * 1000;
    _currSiginRule.end_work_time = [[NSDate date] timeIntervalSince1970] * 1000;
    _currSiginRule.scope = 500;
    _currSiginRule.is_alert = TRUE;
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    _currSiginRule.create_by = employee.employee_guid;
    _currSiginRule.user_guid = _userManager.user.user_guid;
    _currSiginRule.company_no = _userManager.user.currCompany.company_no;
    _workDic = @{@"1":@"周一",@"2":@"周二",@"3":@"周三",@"4":@"周四",@"5":@"周五",@"6":@"周六",@"7":@"周日",};
    //初始化表格视图
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:@"SiginName" bundle:nil] forCellReuseIdentifier:@"SiginName"];
    [_tableView registerNib:[UINib nibWithNibName:@"PunchCardRemind" bundle:nil] forCellReuseIdentifier:@"PunchCardRemind"];
    [_tableView registerNib:[UINib nibWithNibName:@"WorkAdressCell" bundle:nil] forCellReuseIdentifier:@"WorkAdressCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"PalneTableViewCell" bundle:nil] forCellReuseIdentifier:@"PalneTableViewCell"];
    [self setRightNavigationBar];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    switch (section) {
        case 0: count = 1; break;
        case 1: count = 3; break;
        case 2: count = 1 + (_currSiginRule.is_alert ? 2 : 0); break;
        case 3: count = 1 + _currSiginRule.json_list_address_settings.count; break;
        default: count = 1; break;
    }
    return count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 44.f;
    if(indexPath.section == 1)
        return 44.f;
    if(indexPath.section == 2) {
        if(indexPath.row == 0)
            return 70.f;
        return 44.f;
    }
    if(indexPath.section == 3) {
        if(indexPath.row == 0)
            return 44.0f;
        return 70.f;
    }
    return 44.f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    //创建CELL
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {//考勤名称
            cell = [tableView dequeueReusableCellWithIdentifier:@"SiginName" forIndexPath:indexPath];
        } else {//普通
            cell = [tableView dequeueReusableCellWithIdentifier:@"PalneTableViewCell" forIndexPath:indexPath];
        }
    } else if(indexPath.section == 1) {//普通
        cell = [tableView dequeueReusableCellWithIdentifier:@"PalneTableViewCell" forIndexPath:indexPath];
    } else if (indexPath.section == 2) {
        if(indexPath.row == 0) {//打卡
            cell = [tableView dequeueReusableCellWithIdentifier:@"PunchCardRemind" forIndexPath:indexPath];
        } else {//普通
            cell = [tableView dequeueReusableCellWithIdentifier:@"PalneTableViewCell" forIndexPath:indexPath];
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {//普通
            cell = [tableView dequeueReusableCellWithIdentifier:@"PalneTableViewCell" forIndexPath:indexPath];
        } else {//地址
            cell = [tableView dequeueReusableCellWithIdentifier:@"WorkAdressCell" forIndexPath:indexPath];
        }
    } else {//普通
        cell = [tableView dequeueReusableCellWithIdentifier:@"PalneTableViewCell" forIndexPath:indexPath];
    }
    
    //给CELL赋值
    if(indexPath.section == 0) {
        if (indexPath.row == 0) {//考勤名称
            SiginName *nameCell = (id)cell;
            nameCell.data = _currSiginRule;
        } else if (indexPath.row == 1) {//考勤管理人
            PalneTableViewCell *palneCell = (id)cell;
            palneCell.leftImageView.image = [UIImage imageNamed:@"sigin_manager_icon"];
            palneCell.titleLabel.text = @"考勤管理人";
        } else {//参与考勤人员
            PalneTableViewCell *palneCell = (id)cell;
            palneCell.leftImageView.image = [UIImage imageNamed:@"sigin_person_icon"];
            palneCell.titleLabel.text = @"参与考勤人员";
        }
    } else if(indexPath.section == 1) {
        PalneTableViewCell *palneCell = (id)cell;
        if(indexPath.row == 0) {//工作日
            palneCell.leftImageView.image = [UIImage imageNamed:@"work_icon_day"];
            palneCell.titleLabel.text = @"工作日";
            NSMutableArray *workArr = [@[] mutableCopy];
            NSArray *array = [_currSiginRule.work_day componentsSeparatedByString:@","];
            for (NSString *workDay in array)
                [workArr addObject:_workDic[workDay]];
            palneCell.detailLabel.text = [workArr componentsJoinedByString:@","];
        } else if (indexPath.row == 1) {//上班时间
            palneCell.leftImageView.image = [UIImage imageNamed:@"work_up_time"];
            palneCell.titleLabel.text = @"上班时间";
            NSDate *upTime = [NSDate dateWithTimeIntervalSince1970:_currSiginRule.start_work_time / 1000];
            palneCell.detailLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",upTime.hour,upTime.minute];
        } else {//下班时间
            palneCell.leftImageView.image = [UIImage imageNamed:@"work_down_time"];
            palneCell.titleLabel.text = @"下班时间";
            NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:_currSiginRule.end_work_time / 1000];
            palneCell.detailLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",endTime.hour,endTime.minute];;
        }
    } else if (indexPath.section == 2) {
        if(indexPath.row == 0) {//打卡提醒
            PunchCardRemind *remidCell = (id)cell;
            remidCell.delegate = self;
            remidCell.onOffSwitch.on = _currSiginRule.is_alert;
        } else if(indexPath.row == 1) {//上班提醒
            PalneTableViewCell * palneCell = (id)cell;
            palneCell.leftImageView.image = [UIImage imageNamed:@"work_up_time"];
            palneCell.titleLabel.text = @"上班提醒";
            if (_currSiginRule.start_work_time_alert == 0) {
                 palneCell.detailLabel.text = @"准时";
            } else {
                 palneCell.detailLabel.text = [NSString stringWithFormat:@"%@分钟前",@(_currSiginRule.start_work_time_alert)];
            }
        } else {//下班提醒
            PalneTableViewCell * palneCell = (id)cell;
            palneCell.leftImageView.image = [UIImage imageNamed:@"work_down_time"];
            palneCell.titleLabel.text = @"下班提醒";
            if (_currSiginRule.end_work_time_alert == 0) {
                palneCell.detailLabel.text = @"准时";
            } else {
                palneCell.detailLabel.text = [NSString stringWithFormat:@"%@分钟前",@(_currSiginRule.end_work_time_alert)];
            }
        }
    } else if (indexPath.section == 3) {
        if(indexPath.row == 0) {//办公地点
            PalneTableViewCell * palneCell = (id)cell;
            palneCell.leftImageView.image = [UIImage imageNamed:@"location_icon"];
            palneCell.titleLabel.text = @"办公地点";
            palneCell.detailLabel.text = @"添加";
        } else {//办公地址
            WorkAdressCell *workCell = (id)cell;
            workCell.delegate = self;
            workCell.data = _currSiginRule.json_list_address_settings[indexPath.row - 1];
        }
    } else {//误差范围
        PalneTableViewCell * palneCell = (id)cell;
        palneCell.leftImageView.image = [UIImage imageNamed:@"sigin_time_icon"];
        palneCell.titleLabel.text = @"误差范围";
        palneCell.detailLabel.text = [NSString stringWithFormat:@"%@米",@(_currSiginRule.scope)];
    }
    
    //返回CELL
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {//考勤名称 不做任何反应
        } else if (indexPath.row == 1) {//考勤管理人
            
        } else {//参与考勤人员
            
        }
    } else if(indexPath.section == 1) {
        if(indexPath.row == 0) {//选取工作日
            SelectAttendanceWorkDay *workDay = [SelectAttendanceWorkDay new];
            workDay.delegate = self;
            workDay.providesPresentationContextTransitionStyle = YES;
            workDay.definesPresentationContext = YES;
            workDay.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:workDay animated:NO completion:nil];
        } else if (indexPath.row == 1) {//选择上班时间
            SelectAttendanceTime *workDay = [SelectAttendanceTime new];
            workDay.providesPresentationContextTransitionStyle = YES;
            workDay.definesPresentationContext = YES;
            workDay.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:workDay animated:NO completion:nil];
            workDay.selectTimeBlock = ^(int64_t date) {
                _currSiginRule.start_work_time = date;
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            };
        } else {//选择下班时间
            SelectAttendanceTime *workDay = [SelectAttendanceTime new];
            workDay.providesPresentationContextTransitionStyle = YES;
            workDay.definesPresentationContext = YES;
            workDay.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:workDay animated:NO completion:nil];
            workDay.selectTimeBlock = ^(int64_t date) {
                _currSiginRule.end_work_time = date;
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            };
        }
    } else if (indexPath.section == 2) {
        if(indexPath.row == 0) {//打卡提醒 不做任何操作
        } else if (indexPath.row == 1) {//上班时间提醒
            SelectAttendanceSpaceTime *workDay = [SelectAttendanceSpaceTime new];
            workDay.titleNameContent = @"上班时间提醒";
            workDay.providesPresentationContextTransitionStyle = YES;
            workDay.definesPresentationContext = YES;
            workDay.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:workDay animated:NO completion:nil];
            workDay.selectSpaceTimeBlock = ^(NSInteger time) {
                _currSiginRule.start_work_time_alert = time;
                 [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            };
        } else {//下班时间提醒
            SelectAttendanceSpaceTime *workDay = [SelectAttendanceSpaceTime new];
            workDay.titleNameContent = @"下班时间提醒";
            workDay.providesPresentationContextTransitionStyle = YES;
            workDay.definesPresentationContext = YES;
            workDay.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            [self presentViewController:workDay animated:NO completion:nil];
            workDay.selectSpaceTimeBlock = ^(NSInteger time) {
                _currSiginRule.end_work_time_alert = time;
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
            };
        }
    } else if (indexPath.section == 3) {
        if(indexPath.row == 0) { //选择地址
            SelectAdressController *select = [SelectAdressController new];
            select.delegate = self;
            [self.navigationController pushViewController:select animated:YES];
        } else {//地址被选中 不做任何操作
        }
    } else {//选择误差范围
        SelectAttendanceRange *workDay = [SelectAttendanceRange new];
        workDay.delegate = self;
        workDay.providesPresentationContextTransitionStyle = YES;
        workDay.definesPresentationContext = YES;
        workDay.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:workDay animated:NO completion:nil];
    }
}
#pragma mark --
#pragma mark -- SelectAdressDelegate
- (void)selectAdress:(AMapPOI *)adress
{
    if(!adress) return;
    //百度地图地址选择成功
    PunchCardAddressSetting * ruleSet = [[PunchCardAddressSetting alloc] initWithAMapPOI:adress];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"完善地址信息" message:ruleSet.name preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = _userManager.user.currCompany.company_name;
        textField.placeholder = @"修改签到点名称";
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ruleSet.name = [alertVC.textFields[0] text];
        [_currSiginRule.json_list_address_settings addObject:ruleSet];
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:okAction];
    [alertVC addAction:cancleAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark --
#pragma mark -- SelectAttendanceWorkDayDelegate
- (void)selectAttendanceWorkDay:(NSArray<NSNumber*>*)workDays
{
    //工作日选择完毕的回调
    NSMutableArray *strArr = [@[] mutableCopy];
    for (NSNumber *number in workDays) {
        [strArr addObject:[NSString stringWithFormat:@"%@",number]];
    }
    _currSiginRule.work_day = [strArr componentsJoinedByString:@","];
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark --
#pragma mark -- SelectAttendanceRangeDelegate
- (void)selectAttendanceRange:(NSInteger)range
{
    //误差范围选择完毕的回调
    _currSiginRule.scope = range;
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:4]] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- 
#pragma mark -- PunchCardRemindDelegate
- (void)punchCardRemindSwitchAction:(UISwitch*)sw
{
    //打卡提醒cell的开关控件被点击 这里要添加本地推送
    _currSiginRule.is_alert = sw.on;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark --
#pragma mark -- WorkAdressCellDelegate
- (void)workAdressCellBtnAction:(PunchCardAddressSetting *)setting
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"你确定要删除该办公地址？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //办公地点 地址删除按钮被点击
        NSMutableArray *array = [[_currSiginRule.json_list_address_settings NSArray] mutableCopy];
        [array removeObject:setting];
        _currSiginRule.json_list_address_settings = (id)array;
        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
    }];
    [alert addAction:ok];
    [alert addAction:cancle];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark --
#pragma mark -- ConfigNavigationBar
- (void)setRightNavigationBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightNavigationBarAction:)];
}
- (void)rightNavigationBarAction:(UIBarButtonItem*)item {
    //提交考勤规则数据
    if([self checkDataValie]) {
        [self.navigationController.view showLoadingTips:@""];
         //把第一个地址填充到签到规则模型
        Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
        PunchCardAddressSetting *firstAdress = _currSiginRule.json_list_address_settings[0];
        _currSiginRule.address = firstAdress.address;
        _currSiginRule.country = firstAdress.country;
        _currSiginRule.province = firstAdress.province;
        _currSiginRule.city = firstAdress.city;
        _currSiginRule.subdistrict = firstAdress.subdistrict;
        _currSiginRule.create_on_utc = [[NSDate new] timeIntervalSince1970] * 1000;
        _currSiginRule.update_on_utc = [[NSDate new] timeIntervalSince1970] * 1000;
        _currSiginRule.update_by = employee.employee_guid;
        RLMArray<PunchCardAddressSetting> *punchCardAddressSettingArray = [[RLMArray<PunchCardAddressSetting> alloc] initWithObjectClassName:@"PunchCardAddressSetting"];
        int idCount = 0;
        for (PunchCardAddressSetting *setting in _currSiginRule.json_list_address_settings) {
            setting.update_by = employee.employee_guid;
            setting.id = idCount ++;
            [punchCardAddressSettingArray addObject:[setting deepCopy]];
        }
        NSMutableDictionary *dic = [[_currSiginRule JSONDictionary] mutableCopy];
        NSString *str = [[_currSiginRule.json_list_address_settings JSONArray] mj_JSONString];
        [dic setObject:str forKey:@"json_list_address_settings"];
        [UserHttp addSiginRule:dic handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            _currSiginRule.setting_guid = data;
           [self.navigationController.view showSuccessTips:@"添加成功"];
            _currSiginRule.json_list_address_settings = punchCardAddressSettingArray;
           [_userManager addSiginRule:_currSiginRule];
           [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}
//检查数据是否可以提交
- (BOOL)checkDataValie
{
    if([NSString isBlank:_currSiginRule.setting_name]) {
        [self.navigationController.view showMessageTips:@"请输入名称"];
        return NO;
    }
    if(_currSiginRule.json_list_address_settings.count == 0) {
        [self.navigationController.view showMessageTips:@"请选择地址"];
        return NO;
    }
    return YES;
}
@end
