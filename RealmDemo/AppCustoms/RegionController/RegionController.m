//
//  RegionController.m
//  fadein
//
//  Created by Apple on 15/12/13.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import "RegionController.h"
#import "CityController.h"
#import "AreaController.h"
#import <CoreLocation/CoreLocation.h>
@interface RegionController ()<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>
{
    UITableView *_tableView;//显示数据的表格视图
    
    NSDictionary *dataDic;//城市列表字典
    
    UITableViewCell *headerCell;//头部显示定位位置的cell
    
    CLLocationManager *locationManager;//定位
    
    NSString *selectStr;//已选择地区
}
@property (nonatomic, copy) NSString *regionName;//定位的省
@property (nonatomic, copy) NSString *cityName;//定位的市
@property (nonatomic, copy) NSString *areaName;//定位的区

@property (nonatomic, retain) CityController *cityController;

//用户当前位置
@property (nonatomic, assign) CLLocationCoordinate2D locationCoor;

@end

@implementation RegionController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地区";
    headerCell = [UITableViewCell new];
    //获取文件内容
    NSString *fileStr = [[NSBundle mainBundle] pathForResource:@"area" ofType:@"plist" inDirectory:nil forLocalization:nil];
    dataDic = [NSDictionary dictionaryWithContentsOfFile:fileStr];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [self changeState:@"正在定位"];
    [self setupNavigationBar];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor homeListColor];
    
    
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = 100.0f;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestAlwaysAuthorization];
    [locationManager startUpdatingLocation];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)dataDidChange
{
    selectStr = self.data;
}

#pragma mark -定位成功的回调
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [manager stopUpdatingLocation];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];//反向解析，根据及纬度反向解析出地址
    CLLocation *location = [locations objectAtIndex:0];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        for(CLPlacemark *place in placemarks)
        {
            //取出当前位置的坐标
            NSDictionary *dict = [place addressDictionary];
            self.regionName = dict[@"State"];
            self.cityName = dict[@"City"];
            self.areaName = dict[@"SubLocality"];
            [self changeState:@"定位成功"];
            return;
        }
        if(error.code == 2) {
            [self.navigationController.view showFailureTips:@"网络不可用，请连接网络"];
        }
        [self changeState:@"无法定位"];
    }];
}
#pragma mark -定位失败的回道
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
    [self changeState:@"无法定位"];
}
#pragma mark -有多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
#pragma mark -每组的头部视图内容
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"定位到的位置";
    return @"全部城市";
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 41.f;
}

#pragma mark -每组有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    return dataDic.allKeys.count;
}
#pragma mark -改变当前的定位状态
- (void)changeState:(NSString*)state
{
    for (UIView *view in headerCell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(12 + 13 + 20, 7, MAIN_SCREEN_WIDTH - 30, 30)];
    detail.textColor = [UIColor grayColor];
    [headerCell.contentView addSubview:detail];
    if([state isEqualToString:@"正在定位"])
    {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(13, 12, 20, 20)];
        [activityView startAnimating];
        activityView.color = [UIColor blackColor];
        [headerCell.contentView addSubview:activityView];
        detail.text = @"正在定位中...";
    }
    else if ([state isEqualToString:@"无法定位"])
    {
        UIImageView *activityView = [[UIImageView alloc]initWithFrame:CGRectMake(13, 0.5 * (44 - 19), 13, 19)];
        activityView.image = [UIImage imageNamed:@"location_icon"];
        [headerCell.contentView addSubview:activityView];
        detail.text = @"无法获取你的位置信息";
    }
    else
    {
        UIImageView *activityView = [[UIImageView alloc]initWithFrame:CGRectMake(13, 0.5 * (44 - 19), 13, 19)];
        activityView.image = [UIImage imageNamed:@"locationed"];
        [headerCell.contentView addSubview:activityView];
        detail.textColor = [UIColor blackColor];
        detail.text = [NSString stringWithFormat:@"%@ %@ %@",self.regionName,self.cityName,self.areaName];
    }
    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
}
#pragma mark -每行显示的数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if(indexPath.section == 0)
    {
        return headerCell;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CityCell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    NSDictionary *tempDic = dataDic[dataDic.allKeys[indexPath.row]];
    cell.textLabel.text = tempDic.allKeys[0];
    if([tempDic.allKeys[0] isEqualToString:selectStr])
        cell.detailTextLabel.text = @"已选择地区";
    else
        cell.detailTextLabel.text = @"";
    return cell;
}
#pragma mark -点击行的回调
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1)
    {
        self.cityController = [CityController new];
        NSDictionary *tempDic = dataDic[dataDic.allKeys[indexPath.row]];
        self.cityController.cityDic = tempDic[tempDic.allKeys[0]];
        self.cityController.regionName = tempDic.allKeys[0];
        [self.navigationController pushViewController:self.cityController animated:YES];
    }
    else
    {
        if(self.cityName == nil || self.regionName == nil || self.areaName == nil)
        {
            
            [self changeState:@"正在定位"];
            [locationManager stopUpdatingLocation];
            [locationManager startUpdatingLocation];
        }
        else
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(regionSelectAdress:city:area:)])
            {
                [self.delegate regionSelectAdress:self.regionName city:self.cityName area:self.areaName];
            }
            [self.navigationController popViewControllerAnimated:YES];

        }
    }
}



#pragma mark -
#pragma mark - Navigation Config

#pragma mark -- Navigation Bar

- (void)setupNavigationBar {
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:nil];

}

#pragma mark -- Navigation buttons

- (void)setupLeftNavigationButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftNavigationButtonAction:)];
}

- (void)setupRightNavigationButton {
    
}

#pragma mark -- Navigation Actions

- (void)popBackViewController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark - Button Actions

- (void)leftNavigationButtonAction:(id)sender {
    [self popBackViewController];
}

- (void)rightNavigationButtonAction:(id)sender {
    
}








@end
