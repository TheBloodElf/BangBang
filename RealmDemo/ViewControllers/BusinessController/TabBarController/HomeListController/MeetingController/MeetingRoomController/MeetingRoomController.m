//
//  MeetingRoomController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetingRoomController.h"
#import "MeetingRoomDeviceCell.h"
#import "MeetingEquipmentsModel.h"
#import "MeetingDeviceTableCell.h"
#import "MeetingRoomTimeCell.h"
#import "MeetingTimeCell.h"
#import "UserHttp.h"
#import "MeetingDeviceSelectController.h"
#import "MeetDeviceDetailController.h"

@interface MeetingRoomController ()<UITableViewDelegate,UITableViewDataSource,MeetingTimeCellDelegate,MeetingDeviceTableCellDelegate,MeetingDeviceDelegate,MeetingRoomTimeCellDelegate,MeetingDeviceSelectDelegate> {
    UITableView *_tableView;
    UserManager *_userManager;//用户管理器
    Employee *_employee;//会议准备人
    MeetingRoomCellModel *_userSelectDate;//用户选择的开始/结束时间
    NSMutableArray<MeetingRoomModel*> *_allMeetingRoomArr;//所有的会议室
    NSMutableArray<MeetingEquipmentsModel*> *_meetingEquipmentsArr;//已经选择的会议室设备列表
}
@property (nonatomic, strong) MeetingRoomModel *meetingRoomModel;//已经选择的会议室模型
@end

@implementation MeetingRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取会议室列表
    self.title = @"会议室选择";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    _userSelectDate = [MeetingRoomCellModel new];
    _allMeetingRoomArr = [@[] mutableCopy];
    _meetingEquipmentsArr = [@[] mutableCopy];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"MeetingRoomDeviceCell" bundle:nil] forCellReuseIdentifier:@"MeetingRoomDeviceCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MeetingTimeCell" bundle:nil] forCellReuseIdentifier:@"MeetingTimeCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MeetingDeviceTableCell" bundle:nil] forCellReuseIdentifier:@"MeetingDeviceTableCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"MeetingRoomTimeCell" bundle:nil] forCellReuseIdentifier:@"MeetingRoomTimeCell"];
    
    [self.navigationController.view showLoadingTips:@"获取会议室列表..."];
    [UserHttp getMeetRoomList:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            [self.navigationController popViewControllerAnimated:YES];
            return ;
        }
        for (NSDictionary *dic in data) {
            MeetingRoomModel *model = [MeetingRoomModel new];
            [model mj_setKeyValues:dic];
            [_allMeetingRoomArr addObject:model];
        }
        if(_allMeetingRoomArr.count == 0) {
            [self.navigationController.view showFailureTips:@"暂无可用会议室"];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        self.meetingRoomModel = _allMeetingRoomArr[0];
        [self.view addSubview:_tableView];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightClicked:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    if(self.delegate && [self.delegate respondsToSelector:@selector(MeetingRoomDeviceSelect: meetingRoom:employee:meetingRoomTime:)]) {
        [self.delegate MeetingRoomDeviceSelect:_meetingEquipmentsArr meetingRoom:_meetingRoomModel employee:_employee meetingRoomTime:_userSelectDate];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 1)
        if(_meetingEquipmentsArr.count)
            return 2;
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
        return 100;
    if(indexPath.section == 1)
        return 60;
    //根据当前所选会议室的开始结束时间算出高度
    CGFloat height = 85;
    NSInteger count = (_meetingRoomModel.end_time - _meetingRoomModel.begin_time) / (30 * 60 * 1000);
    if((_meetingRoomModel.end_time - _meetingRoomModel.begin_time) % (30 * 60 * 1000) != 0)
        count ++;
    height += ((MAIN_SCREEN_WIDTH - 60) / 7.f) * count;
    return height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingRoomDeviceCell" forIndexPath:indexPath];
    } else if (indexPath.section == 1) {
        if(indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingTimeCell" forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingDeviceTableCell" forIndexPath:indexPath];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MeetingRoomTimeCell" forIndexPath:indexPath];
    }
    
    if(indexPath.section == 0) {//会议室列表
        MeetingRoomDeviceCell *device = (id)cell;
        device.delegate = self;
        device.meetingRoomModel = self.meetingRoomModel;
        device.data = _allMeetingRoomArr;
    } else if (indexPath.section == 1) {
        if(indexPath.row == 0) {//会议室时间
            MeetingTimeCell *time = (id)cell;
            time.delegate = self;
            time.data = _userSelectDate;
        } else {//会议室设备
            MeetingDeviceTableCell *device = (id)cell;
            device.delegate = self;
            device.data = _meetingEquipmentsArr;
        }
    } else {//会议室时间选择
        MeetingRoomTimeCell *roomTime = (id)cell;
        roomTime.data = self.meetingRoomModel;
        roomTime.delegate = self;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark -- MeetingRoomTimeCellDelegate
- (void)MeetingRoomSelectDate:(MeetingRoomCellModel*)model {
    _userSelectDate = model;
    if(_employee.id != 0)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- MeetingDeviceDelegate
//某个会议室被选择
- (void)MeetingDeviceSelect:(MeetingRoomModel*)device {
    //清除用户选择的时间
    _userSelectDate = [MeetingRoomCellModel new];
    //移除设备
    [_meetingEquipmentsArr removeAllObjects];
    //重新刷新列表
    self.meetingRoomModel = device;
    [_tableView reloadData];
}
#pragma mark -- MeetingTimeCellDelegate
//会议设备被点击
- (void)MeetingTimeDevice {
    MeetingDeviceSelectController *select = [MeetingDeviceSelectController new];
    select.delegate = self;
    [self.navigationController pushViewController:select animated:YES];
}
#pragma mark -- MeetingDeviceSelectDelegate
- (void)MeetingDeviceSelect:(NSArray<MeetingEquipmentsModel*>*)array employee:(Employee*)employee {
    NSMutableArray *idArray = [@[] mutableCopy];
    for (MeetingEquipmentsModel *model in array) {
        [idArray addObject:@(model.id).stringValue];
    }
    _meetingEquipmentsArr = [array mutableCopy];
    _employee = employee;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark -- MeetingDeviceTableCellDelegate
//更多按钮被点击
- (void)MeetingDeviceTableMore {
    MeetDeviceDetailController *meet = [MeetDeviceDetailController new];
    meet.employee = _employee;
    meet.meetingEquipments = _meetingEquipmentsArr;
    [self.navigationController pushViewController:meet animated:YES];
}
@end
