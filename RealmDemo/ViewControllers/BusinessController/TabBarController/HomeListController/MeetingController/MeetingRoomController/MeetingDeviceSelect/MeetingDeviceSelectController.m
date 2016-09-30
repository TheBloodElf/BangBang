//
//  MeetingDeviceSelectController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingDeviceSelectController.h"
#import "MeetingRoomCellModel.h"
#import "MeetingDeviceSelectCell.h"
#import "MeetingSelectPresonCell.h"
#import "UserHttp.h"
#import "SingleSelectController.h"

@interface MeetingDeviceSelectController ()<UITableViewDelegate,UITableViewDataSource,SingleSelectDelegate> {
    NSMutableArray<MeetingEquipmentsModel*> *_sureEquipmentsArr;//固定设备 是一个对象数组
    NSMutableArray<MeetingEquipmentsModel*> *_publicEquipmentsArr;//公共设备 是一个对象数组
    Employee *_employee;//会议设备准备人
    UserManager *_userManager;
    UITableView *_tableView;
}

@end

@implementation MeetingDeviceSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择设备";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    _employee = [Employee new];
    _sureEquipmentsArr = [@[] mutableCopy];
    _publicEquipmentsArr = [@[] mutableCopy];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"MeetingSelectPresonCell" bundle:nil] forCellReuseIdentifier:@"MeetingSelectPresonCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MeetingDeviceSelectCell" bundle:nil] forCellReuseIdentifier:@"MeetingDeviceSelectCell"];
    //会议准备人为会议室带入的名字
    for (Employee *employee in [_userManager getEmployeeWithCompanyNo:_userManager.user.currCompany.company_no status:5]) {
        if([employee.employee_guid isEqualToString:_meetingRoomModel.in_charge]) {
            _employee = employee;
            break;
        }
    }
    //从会议室模型中获取固定设备
    int i = -1;
    for (NSString *str in [self.meetingRoomModel.room_equipments componentsSeparatedByString:@","]) {
        if([NSString isBlank:str]) continue;
        MeetingEquipmentsModel *model = [MeetingEquipmentsModel new];
        model.type = 0;
        model.id = i--;
        model.name = str;
        model.isSelect = YES;
        [_sureEquipmentsArr addObject:model];
    }
    //获取公共设备
    [self.navigationController.view showLoadingTips:@"获取公共设备..."];
    [UserHttp getMeetEquipments:_userManager.user.currCompany.company_no begin:_userSelectDate.begin.timeIntervalSince1970 * 1000 end:_userSelectDate.end.timeIntervalSince1970 * 1000 handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            [self.navigationController popViewControllerAnimated:YES];
            return ;
        }
        for (NSDictionary *dic in data) {
            MeetingEquipmentsModel *model = [MeetingEquipmentsModel new];
            [model mj_setKeyValues:dic];
            [_publicEquipmentsArr addObject:model];
        }
        [self.view addSubview:_tableView];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)rightClicked:(UIBarButtonItem*)item {
    //获取公共设备被选中的
    NSMutableArray<MeetingEquipmentsModel*> *array = [@[] mutableCopy];
    for (MeetingEquipmentsModel *model in _publicEquipmentsArr) {
        if(model.isSelect == YES)
            [array addObject:model];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingDeviceSelect:employee:)]) {
        [self.delegate MeetingDeviceSelect:array employee:_employee];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"准备人";
    if(section == 1)
        return @"固定设备";
    return @"公共设备";
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    if(section == 1)
        return _sureEquipmentsArr.count;
    return _publicEquipmentsArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        MeetingSelectPresonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingSelectPresonCell" forIndexPath:indexPath];
        cell.data = _employee;
        return cell;
    }
    MeetingDeviceSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingDeviceSelectCell" forIndexPath:indexPath];
    if(indexPath.section == 1)
        cell.data = _sureEquipmentsArr[indexPath.row];
    else
        cell.data = _publicEquipmentsArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0) {//选人
        SingleSelectController *select = [SingleSelectController new];
        select.delegate = self;
        [self.navigationController pushViewController:select animated:YES];
    } else if (indexPath.section == 1) {//固定设备
        
    } else {//公共设备
        _publicEquipmentsArr[indexPath.row].isSelect = !_publicEquipmentsArr[indexPath.row].isSelect;
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}
#pragma mark -- SingleSelectDelegate
-(void)singleSelect:(Employee *)employee {
    _employee = employee;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}
@end
