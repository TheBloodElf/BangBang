//
//  MeetDeviceDetailController.m
//  RealmDemo
//
//  Created by Mac on 16/7/30.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MeetDeviceDetailController.h"

@interface MeetDeviceDetailController ()<UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray<MeetingEquipmentsModel*> *_sureEquipmentsArr;//固定设备
    NSMutableArray<MeetingEquipmentsModel*> *_publicEquipmentsArr;//公共设备
    UITableView *_tableView;
}

@end

@implementation MeetDeviceDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设备详情";
    _sureEquipmentsArr = [@[] mutableCopy];
    _publicEquipmentsArr = [@[] mutableCopy];
    //获取固定设备
    int i = -1;
    for (NSString *str in [self.meetingRoomModel.room_equipments componentsSeparatedByString:@","]) {
        if([NSString isBlank:str]) continue;
        MeetingEquipmentsModel *model = [MeetingEquipmentsModel new];
        model.id = i--;
        model.name = str;
        model.type = 0;
        [_sureEquipmentsArr addObject:model];
    }
    for (MeetingEquipmentsModel *model in self.meetingEquipments) {
        [_publicEquipmentsArr addObject:model];
    }
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    if(indexPath.section == 0) {
        cell.textLabel.text = _employee.real_name;
    } else if (indexPath.section == 1) {
        cell.textLabel.text = [_sureEquipmentsArr[indexPath.row] name];
    } else {
        cell.textLabel.text = [_publicEquipmentsArr[indexPath.row] name];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
