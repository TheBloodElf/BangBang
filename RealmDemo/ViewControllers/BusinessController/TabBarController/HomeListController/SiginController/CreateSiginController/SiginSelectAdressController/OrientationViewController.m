#import "OrientationViewController.h"
#import "UserManager.h"
#import <MapKit/MapKit.h>
#import <MAMapKit/MAOverlay.h>

@interface OrientationViewController ()<MAMapViewDelegate,AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UserManager *_userManager;//用户管理器
    MAUserLocation *currUserLocation;//用户当前位置，提高定位精准度
    MAMapView *_mapView;//地图
    AMapSearchAPI *_search;//搜索
    NSMutableArray *_poiArray;// 搜索高德poi数组结果
    UITableView *poiTableView;//地址表格视图
    //#137
    NSInteger selectedRow;//当前选择的地址行下标
}

@end

@implementation OrientationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"定位";
    _poiArray = [@[] mutableCopy];
    _userManager = [UserManager manager];
    //地图初始化
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 364)];
    _mapView.delegate = self;
    _mapView.zoomLevel = 13;//地图缩放级别
    _mapView.rotateEnabled = NO;
    _mapView.distanceFilter = 100;
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    _mapView.showsUserLocation = YES;//是否显示用户位置
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishOrientationClick)];
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
    if(_poiArray.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    //获取已经选择的位置
    AMapPOI *selectedPoi = _poiArray[selectedRow];
    if (_setting && _category < 2) {
        //判断当前选择位置是否在圈内
        if(!MACircleContainsCoordinate(CLLocationCoordinate2DMake(_setting.latitude, _setting.longitude),CLLocationCoordinate2DMake(selectedPoi.location.latitude, selectedPoi.location.longitude),_currSiginRule.scope)){
            [self.navigationController.view showMessageTips:@"当前离签到点太远"];
            return;
        }
    }
    //回调传值
    if (_finishOrientation)
        _finishOrientation(_poiArray[selectedRow]);
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
    NSMutableArray *poiArr = [@[] mutableCopy];
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        [poiArr addObject:obj];
    }];
    _poiArray = poiArr;
    //如果有标注 就去掉
    if(_mapView.annotations.count > 0) {
        [_mapView removeAnnotations:_mapView.annotations];
    }
    //选中的地址改变了 刷新标注
    //#144-1
    if(_poiArray.count > 0) {
        //搜索结果把第一个默认选中
        selectedRow = 0;
        POIAnnotation *currentPOIAnnotation = [[POIAnnotation alloc] initWithPOI:[_poiArray objectAtIndex:selectedRow]];
        [_mapView addAnnotation:currentPOIAnnotation];
    }
    [poiTableView reloadData];
    
    
    //默认选中用户常用位置
    //外勤和其他直接可以不判断用户常用地址
    if(self.category >= 2) return;
    //没有搜索结果就退出
    if(_poiArray.count == 0) return;
    Employee *owner = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    //取出用户最近10天的签到地址
    NSMutableArray<SignIn*> *signInArr = [@[] mutableCopy];
    NSDate *currDate = [NSDate date];
    for (int i = 0; i < 9; i ++) {
        NSDate *temp = [currDate dateByAddingTimeInterval: - i * 24 * 60 * 60];
        [signInArr addObjectsFromArray:[_userManager getTodaySigInListGuid:owner.employee_guid siginDate:temp]];
    }
    //没有信息就退出
    if(signInArr.count == 0) return;
    //计算出签到点最多的地址 用两个数组来装，一个数组装签到地址（相同经纬度只装一个），对于下标另一个数组装次数
    NSMutableArray<SignIn*> *computeSigInArr = [@[] mutableCopy];
    NSMutableArray<NSNumber*> *computeSigInnumberArr = [@[] mutableCopy];
    for (SignIn *currSignIn in signInArr) {
        //查看当前地址是不是在计算数组中
        for (int i = 0;i < computeSigInArr.count;i ++) {
            SignIn *temp = computeSigInArr[i];
            if(currSignIn.longitude == temp.longitude)
                if(currSignIn.latitude == temp.latitude) {
                    //如果有相同的经纬度，就把次数数组加1
                    computeSigInnumberArr[i] = @([computeSigInnumberArr[i] intValue] + 1);
                    break;
                }
        }
        //如果没有相同的经纬度，两个数组分别加一个
        [computeSigInArr addObject:currSignIn];
        [computeSigInnumberArr addObject:@(1)];
    }
    //计算出最多次数的签到地址
    int maxCount = 0;
    int index = 0;
    for (int i = 0;i < computeSigInnumberArr.count;i ++) {
        NSNumber *number = computeSigInnumberArr[i];
        if(number.intValue > maxCount) {
            maxCount = number.intValue;
            index = i;
        }
    }
    SignIn *maxNumberSignIn = computeSigInArr[index];
    //看一下搜索出来的地址中有没有同经纬度一样的，有就默认选中
    for (int i = 0;i < _poiArray.count;i ++) {
        AMapPOI *aMapPOI = _poiArray[i];
        if(aMapPOI.location.longitude == maxNumberSignIn.longitude)
            if(aMapPOI.location.latitude == maxNumberSignIn.latitude) {
                selectedRow = i;
                //如果有标注 就去掉
                if(_mapView.annotations.count > 0) {
                    [_mapView removeAnnotations:_mapView.annotations];
                }
                POIAnnotation *currentPOIAnnotation = [[POIAnnotation alloc] initWithPOI:[_poiArray objectAtIndex:selectedRow]];
                [_mapView addAnnotation:currentPOIAnnotation];
                break;
            }
    }
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    if(error.code == 1806) {
        [self.navigationController.view showFailureTips:@"网络不可用，请连接网络"];
    }
}
#pragma mark - TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _poiArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *poiCellIdentifier = @"poiCellIdentifeir";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:poiCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:poiCellIdentifier];
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"repeat_radio_selected"]];
        image.frame = CGRectMake(MAIN_SCREEN_WIDTH - 30, 20, 14, 14);
        image.tag = 10001;
        [cell.contentView addSubview:image];
    }
    UIImageView *image = [cell.contentView viewWithTag:10001];
    image.hidden = YES;
    AMapPOI *poi = [_poiArray objectAtIndex:indexPath.row];
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@%@", poi.province,poi.city,poi.district,poi.address];
    if (indexPath.row == selectedRow)
        image.hidden = NO;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedRow = indexPath.row;
    //如果有标注 就去掉
    if(_mapView.annotations.count > 0) {
        [_mapView removeAnnotations:_mapView.annotations];
    }
    //添加标注
    POIAnnotation *currentPOIAnnotation = [[POIAnnotation alloc] initWithPOI:[_poiArray objectAtIndex:indexPath.row]];
    [_mapView addAnnotation:currentPOIAnnotation];
    [poiTableView reloadData];
}

@end
