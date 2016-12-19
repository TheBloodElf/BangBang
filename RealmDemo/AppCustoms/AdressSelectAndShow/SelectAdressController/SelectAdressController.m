//
//  SelectAdressController.m
//  fadein
//
//  Created by Apple on 16/1/14.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "SelectAdressController.h"
#import "SelectAdressTableCell.h"
#import "MJRefresh.h"
#import "SelectAdressTableCell.h"
#import "NoResultView.h"
#import "SearchAdressController.h"

@interface SelectAdressController ()<MAMapViewDelegate,UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate,SearchAdressDelegate> {
    AMapSearchAPI *_searchAPI;//高德搜索API
    AMapPOIAroundSearchRequest *_searchPOIRequest;//周边搜索句柄
    MAMapView *_mapView;//高德地图
    MAUserLocation *_currUserLocation;//当前用户位置
    NSMutableArray<AMapPOI*> *_searchDataArr;//搜索结果数组
    AMapPOI *_userSelectedPOI;//用户已经选择的位置
    UITableView *_tableView;//展示数据的表格视图
    NoResultView *_noResultView;//没有结果的视图
}

@end

@implementation SelectAdressController

#pragma mark -- 
#pragma mark -- LifeStyle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择位置";
    self.view.backgroundColor = [UIColor whiteColor];
    //配置高德地图
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 250 + 64)];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.zoomLevel = 16.f;
    _mapView.rotateEnabled = NO;
    [self.view addSubview:_mapView];
    UIImageView *centerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location_center_icon"]];
    centerView.frame = CGRectMake(0.5 * (_mapView.frame.size.width - centerView.frame.size.width), 125 - centerView.frame.size.height, centerView.frame.size.width, centerView.frame.size.height);
    [_mapView addSubview:centerView];
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(5, 250 - 5 - 35, 35, 35);
    [locationBtn setImage:[UIImage imageNamed:@"start_location_btn"] forState:UIControlStateNormal];
    [locationBtn addTarget:self action:@selector(startLocation) forControlEvents:UIControlEventTouchUpInside];
    _mapView.userInteractionEnabled = YES;
    [_mapView addSubview:locationBtn];
    
    UIButton *smallScaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    smallScaleBtn.frame = CGRectMake(_mapView.frame.size.width - 5 - 35, 250 - 5 - 35, 35, 35);
    smallScaleBtn.backgroundColor = [UIColor whiteColor];
    [smallScaleBtn setImage:[UIImage imageNamed:@"small_scale_icon"] forState:UIControlStateNormal];
    [smallScaleBtn addTarget:self action:@selector(smallScale) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:smallScaleBtn];
    
    UIButton *bigScaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    bigScaleBtn.backgroundColor = [UIColor whiteColor];
    bigScaleBtn.frame = CGRectMake(_mapView.frame.size.width - 5 - 35 , 250 - 5 - 35 - 36, 35, 35);
    [bigScaleBtn setImage:[UIImage imageNamed:@"big_scale_icon"] forState:UIControlStateNormal];
    [bigScaleBtn addTarget:self action:@selector(bigScale) forControlEvents:UIControlEventTouchUpInside];
    [_mapView addSubview:bigScaleBtn];

    CGFloat spaceWidth = 25;
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(_mapView.frame.size.width - 5 - (35 - spaceWidth) / 2.0 - spaceWidth,  _mapView.frame.size.height - 5 - 35 - 1, spaceWidth, 1)];
    spaceView.backgroundColor = [UIColor grayColor];
    [_mapView addSubview:spaceView];
    
    //配置表格
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 250, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 250 - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"SelectAdressTableCell" bundle:nil] forCellReuseIdentifier:@"SelectAdressTableCell"];
    [self.view addSubview:_tableView];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _searchPOIRequest.page = 0;
        [self searchPOIData];
    }];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _searchPOIRequest.page ++;
        [self searchPOIData];
    }];
    _noResultView = [[NoResultView alloc] initWithFrame:_tableView.bounds];
    
    //配置POI搜索
    _searchAPI = [[AMapSearchAPI alloc] init];
    _searchAPI.delegate = self;
    _searchPOIRequest = [[AMapPOIAroundSearchRequest alloc] init];
    _searchPOIRequest.page = 0;
    _searchPOIRequest.radius = 500;
    _searchPOIRequest.requireExtension = YES;
    _searchDataArr = [@[] mutableCopy];
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(rightNavigationBarAction:)],[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(goToSearchAdressController:)]];
    // Do any additional setup after loading the view from its nib.
}
//开始定位
- (void)startLocation {
    [_mapView setCenterCoordinate:_mapView.userLocation.location.coordinate animated:YES];
}
//缩小比例
- (void)smallScale {
    CGFloat scale = _mapView.zoomLevel;
    [_mapView setZoomLevel:scale - 0.3 atPivot:_mapView.center animated:YES];
}
//增加比例
- (void)bigScale {
    CGFloat scale = _mapView.zoomLevel;
    [_mapView setZoomLevel:scale + 0.3 atPivot:_mapView.center animated:YES];
}
//高德搜索数据
- (void)searchPOIData {
    [_searchAPI AMapPOIAroundSearch:_searchPOIRequest];
}
#pragma mark -- 
#pragma mark -- SearchAdressDelegate
- (void)searchAdress:(AMapPOI *)aMapPOI
{
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(aMapPOI.location.latitude, aMapPOI.location.longitude) animated:YES];
}

#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchDataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectAdressTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectAdressTableCell" forIndexPath:indexPath];
    AMapPOI *poi = _searchDataArr[indexPath.row];
    cell.adressTitle.text = poi.name;
    cell.adressDetail.text = poi.address;
    if ([poi isEqual:_userSelectedPOI]) {
        cell.isSelectedBtn.selected = YES;
    } else {
         cell.isSelectedBtn.selected = NO;
    }
    return cell;
}
#pragma mark -- 
#pragma mark -- MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    //得到当前地图中心点的位置信息
    CLLocationCoordinate2D d2d = [mapView convertPoint:_mapView.center toCoordinateFromView:_mapView];
    //地图中心点发生变化
    _searchPOIRequest.location = [AMapGeoPoint locationWithLatitude:d2d.latitude longitude:d2d.longitude];
    [_tableView.mj_header beginRefreshing];
}
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //得到当前地图中心点的位置信息
    CLLocationCoordinate2D d2d = [mapView convertPoint:_mapView.center toCoordinateFromView:_mapView];
    //地图中心点发生变化
    _searchPOIRequest.location = [AMapGeoPoint locationWithLatitude:d2d.latitude longitude:d2d.longitude];
    [_tableView.mj_header beginRefreshing];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _userSelectedPOI = _searchDataArr[indexPath.row];
    [_tableView reloadData];
}
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    //只是第一次使得地图移动到用户位置
    if(!_currUserLocation)
        [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    _currUserLocation = userLocation;
}
#pragma mark --
#pragma mark -- AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    if(error.code == 1806) {
        [self.navigationController.view showFailureTips:@"网络不可用，请连接网络"];
    }
}
- (void)onPOISearchDone:(AMapPOIAroundSearchRequest *)request response:(AMapPOISearchResponse *)response
{
    //POI搜索结果回调
    if(request.page == 0)
        _searchDataArr = [@[] mutableCopy];
    [_searchDataArr addObjectsFromArray:response.pois];
    if(request.page == 0) {
        if(_searchDataArr.count != 0) {
            _userSelectedPOI = _searchDataArr[0];
        } else {
            _userSelectedPOI = nil;
        }
    }
    [_tableView.mj_header endRefreshing];
    if(_tableView.mj_footer != (id)_noResultView)
        [_tableView.mj_footer endRefreshing];
    if(_searchDataArr.count == 0) {
        _tableView.mj_footer = (id)_noResultView;
    } else {
        _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            _searchPOIRequest.page ++;
            [self searchPOIData];
        }];
    }
    [_tableView reloadData];
}
- (void)goToSearchAdressController:(UIBarButtonItem*)item {
    SearchAdressController *search = [SearchAdressController new];
    search.delegate = self;
    [self.navigationController pushViewController:search animated:YES];
}

- (void)rightNavigationBarAction:(UIBarButtonItem*)item {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectAdress:)]) {
        [self.delegate selectAdress:_userSelectedPOI];
    }
}

@end
