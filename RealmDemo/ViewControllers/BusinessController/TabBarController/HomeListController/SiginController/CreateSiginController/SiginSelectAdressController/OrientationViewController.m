#import "OrientationViewController.h"
#import <MapKit/MapKit.h>
#import <MAMapKit/MAOverlay.h>

@interface OrientationViewController ()<MAMapViewDelegate,AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate>
{
    MAUserLocation *currUserLocation;//当前位置，提高定位精准度
    MAMapView *_mapView;
    AMapSearchAPI *_search;
    NSMutableArray *poiArray;
    NSMutableArray *poiAnnotations;
    UITableView *poiTableView;
    NSInteger selectedRow;
    //当前图上标注
    POIAnnotation *currentPOIAnnotation;
}

@end

@implementation OrientationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"定位";
    poiArray = [NSMutableArray new];
    poiAnnotations = [NSMutableArray new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishOrientationClick)];
    //地图初始化
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 364)];
    _mapView.delegate = self;
    _mapView.zoomLevel = 13;//地图缩放级别
    _mapView.rotateEnabled = NO;
    _mapView.distanceFilter = 100;
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    //是否定位
    _mapView.showsUserLocation = YES;
    //设置定位模式
    [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
    [self.view addSubview:_mapView];
    //搜索初始化
    _search = [[AMapSearchAPI alloc]init];
    _search.delegate = self;
    
    //列表初始化
    poiTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 300, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 300 - 64) style:UITableViewStylePlain];
    poiTableView.delegate = self;
    poiTableView.dataSource = self;
    poiTableView.rowHeight = 60.0;
    poiTableView.tableFooterView = [UIView new];
    [self.view addSubview:poiTableView];
    
    //根据打卡点设置范围
    if (_setting && _category < 2) {
        MACircle *cicle = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(_setting.latitude, _setting.longitude) radius:_currSiginRule.scope];
        [_mapView addOverlay:cicle level:MAOverlayLevelAboveRoads];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark - CustoMethods
/**
 *  定位完成
 */
-(void)finishOrientationClick{
    if(poiArray.count == 0) {
         [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    AMapPOI *selectedPoi = poiArray[selectedRow];
    if (_setting && _category < 2) {
        //判断当前选择位置是否在圈内
        if(!MACircleContainsCoordinate(CLLocationCoordinate2DMake(_setting.latitude, _setting.longitude),CLLocationCoordinate2DMake(selectedPoi.location.latitude, selectedPoi.location.longitude),_currSiginRule.scope)){
            [self.navigationController.view showMessageTips:@"当前离签到点太远"];
            return;
        }
    }
    if (_finishOrientation) {
        _finishOrientation(poiArray[selectedRow]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 定位代理方法
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (!currUserLocation) {
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        currUserLocation = userLocation;
        //根据位置请求当前位置的POI
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        request.location = [AMapGeoPoint locationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
        /* 按照距离排序. */
        request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
        request.sortrule = 0;
        request.requireExtension = YES;
        request.radius = 300;
        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude) animated:YES];
        [_search AMapPOIAroundSearch:request];
    }
}
- (MAOverlayPathRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
    MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithOverlay:overlay];
    circleRenderer.lineWidth   = 2.f;
    circleRenderer.strokeColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
    circleRenderer.fillColor   = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
    return circleRenderer;
}
#pragma mark - 搜索代理方法
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
        return;
    NSMutableArray *annotionArr = [@[] mutableCopy];
    NSMutableArray *poiArr = [@[] mutableCopy];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        [annotionArr addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        [poiArr addObject:obj];
    }];
    poiArray = poiArr;
    poiAnnotations = annotionArr;
    selectedRow = 0;
    [poiTableView reloadData];
    //选中的地址改变了 刷新标注
    currentPOIAnnotation = [[POIAnnotation alloc] initWithPOI:[poiArray objectAtIndex:selectedRow]];
    [_mapView addAnnotation:currentPOIAnnotation];

}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    if(error.code == 1806) {
        [self.navigationController.view showFailureTips:@"网络不可用，请连接网络"];
    }
}
#pragma mark - TableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return poiArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *poiCellIdentifier = @"poiCellIdentifeir";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:poiCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:poiCellIdentifier];
        UIImageView *image = [[UIImageView alloc]initWithImage:nil highlightedImage:[UIImage imageNamed:@"repeat_radio_selected"]];
        image.frame = CGRectMake(MAIN_SCREEN_WIDTH - 30, 20, 14, 14);
        [cell.contentView addSubview:image];
    }
    AMapPOI *poi = [poiArray objectAtIndex:indexPath.row];
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@%@", poi.province,poi.city,poi.district,poi.address];
    if (indexPath.row == selectedRow) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedRow = indexPath.row;
    [_mapView removeAnnotation:currentPOIAnnotation];
    //选中的地址改变了 刷新标注
    currentPOIAnnotation = [[POIAnnotation alloc] initWithPOI:[poiArray objectAtIndex:indexPath.row]];
    [_mapView addAnnotation:currentPOIAnnotation];
}

@end
