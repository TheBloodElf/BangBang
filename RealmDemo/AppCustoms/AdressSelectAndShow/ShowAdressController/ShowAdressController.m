//
//  ShowAdressController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/5.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ShowAdressController.h"
#import "POIAnnotation.h"

@interface ShowAdressController () {
    MAMapView *_mapView;//百度地图
}

@end

@implementation ShowAdressController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地址";
    self.view.backgroundColor = [UIColor whiteColor];
    //配置百度地图
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    _mapView.showsUserLocation = YES;
    _mapView.zoomLevel = 16.f;
    _mapView.rotateEnabled = NO;
    [self.view addSubview:_mapView];
    //把中心店移动到用户输入位置
    [_mapView setCenterCoordinate:self.cLLocationCoordinate2D animated:YES];
    
    AMapPOI *aMapPOI = [AMapPOI new];
    aMapPOI.location = [AMapGeoPoint locationWithLatitude:self.cLLocationCoordinate2D.latitude longitude:self.cLLocationCoordinate2D.longitude];
    POIAnnotation *currentPOIAnnotation = [[POIAnnotation alloc] initWithPOI:aMapPOI];
    [_mapView addAnnotation:currentPOIAnnotation];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
@end
