//
//  SiginController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SiginController.h"
#import "UserManager.h"
#import "CreateSiginController.h"
#import "MoreSelectView.h"
#import "UserHttp.h"
#import "IdentityManager.h"
#import "SigInListCell.h"
#import "AttendanceRollController.h"
#import "PlainPhotoBrose.h"
#import "WebNonstandarViewController.h"
#import "SiginNoteController.h"
#import "ShowAdressController.h"
#import "DotActivityIndicatorView.h"
#import "NoResultView.h"
//天气信息获取流程：地图定位->poi搜索去第一个地址的城市->搜索天气->填充地址标签
@interface SiginController ()<MoreSelectViewDelegate,UITableViewDelegate,UITableViewDataSource,RBQFetchedResultsControllerDelegate,AMapSearchDelegate,SigInListCellDelegate,MAMapViewDelegate> {
    UIButton *_leftNavigationBarButton;//左边导航的按钮
    UIButton *_rightBtn;//右边导航按钮
    NoResultView *_noDataView;//没有数据的视图
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据库监听
    RBQFetchedResultsController *_siginListFetchedResultsController;//今天的签到记录
    RBQFetchedResultsController *_employeeFetchedResultsController;//员工数据监听
    MoreSelectView *_moreSelectView;//多选视图
    NSMutableArray<SignIn*> *_todaySigInArr;//今天签到的数组
    
    MAUserLocation *currUserLocation;//当前位置，用于只获取第一次地址的标示
    MAMapView *_mapView;//使用地图来定位 更准确 #BANG-524
    AMapSearchAPI *_search;//搜索
    
    BOOL isFirstLoad;
    //当前圈子上/下班签到次数
    int currCompanySiginCount;
    //所有圈子中最多的签到次数 -1表示还没有计算完成
    int maxCompanySiginCount;
}
@property (weak, nonatomic) IBOutlet UILabel *todatSiginNumber;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SiginController

- (void)viewDidLoad {
    [super viewDidLoad];
    maxCompanySiginCount = -1;//-1表示还没有计算完成
    _todaySigInArr = [@[] mutableCopy];
    _userManager = [UserManager manager];
    currUserLocation = [MAUserLocation new];
    [self.tableView registerNib:[UINib nibWithNibName:@"SigInListCell" bundle:nil] forCellReuseIdentifier:@"SigInListCell"];
    self.view.backgroundColor = [UIColor whiteColor];
    DotActivityIndicatorView *loadView = [[DotActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 240)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = loadView;
    //把视图移动到最顶部 即使有状态栏和导航
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [self countSigin];
    [self setLeftNavigationBarItem];
    [self setRightNavigationBarItem];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor siginColor];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //是不是第一次加载这个页面
    if(isFirstLoad) return;
    isFirstLoad = YES;
    
    [self updateTime];
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    //创建表格视图
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    _siginListFetchedResultsController = [_userManager createSigInListFetchedResultsController];
    _siginListFetchedResultsController.delegate = self;
    _employeeFetchedResultsController = [_userManager createEmployeesFetchedResultsControllerWithCompanyNo:_userManager.user.currCompany.company_no];
    _employeeFetchedResultsController.delegate = self;
    //展示今天的签到记录
    _todaySigInArr = [_userManager getSigInListGuid:employee.employee_guid siginDate:[NSDate date]];
    self.todatSiginNumber.text = [NSString stringWithFormat:@"今日已签到%ld次",_todaySigInArr.count];
    _noDataView = [[NoResultView alloc] initWithFrame:self.tableView.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    if(_todaySigInArr.count)
        self.tableView.tableFooterView = [UIView new];
    else
        self.tableView.tableFooterView = _noDataView;
    [_tableView reloadData];
    //使用地图定位提高准确度
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _mapView.delegate = self;
    _mapView.hidden = YES;
    _mapView.zoomLevel = 13;//地图缩放级别
    _mapView.distanceFilter = 100;
    _mapView.rotateEnabled = NO;
    _mapView.showsUserLocation = YES;
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    //用地图进行定位 比较准确
    [self.view addSubview:_mapView];
    //初始化搜索
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
//    _locationManager = [[CLLocationManager alloc]init];
//    _locationManager.delegate = self;
//    _locationManager.distanceFilter = 100.0f;
//    [_locationManager startUpdatingLocation];
    //从服务器获取签到记录
    [UserHttp getSiginList:_userManager.user.currCompany.company_no employeeGuid:employee.employee_guid handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *dic in data) {
            SignIn *sigIn = [SignIn new];
            [sigIn mj_setKeyValues:dic];
            sigIn.descriptionStr = dic[@"description"];
            [array addObject:sigIn];
        }
        [_userManager updateTodaySinInList:array guid:employee.employee_guid];
    }];
    //BANG-187 管理员权限不能实时获取
    [self getCurrEmployee];
}
- (void)getCurrEmployee {
    //从网络上获取最新的员工数据
    [UserHttp getEmployeeCompnyNo:_userManager.user.currCompany.company_no status:5 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *dic in data[@"list"]) {
            Employee *employee = [Employee new];
            [employee mj_setKeyValues:dic];
            [array addObject:employee];
        }
        [UserHttp getEmployeeCompnyNo:_userManager.user.currCompany.company_no status:0 userGuid:_userManager.user.user_guid handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            for (NSDictionary *dic in data[@"list"]) {
                Employee *employee = [Employee new];
                [employee mj_setKeyValues:dic];
                [array addObject:employee];
            }
            //存入本地数据库
            [_userManager updateEmployee:array companyNo:_userManager.user.currCompany.company_no];
        }];
    }];
}
//一直刷新时间
- (void)updateTime {
    NSDate *currDate = [NSDate date];
    self.dateLabel.text = [NSString stringWithFormat:@"%02ld月%02ld日 %@",currDate.month,currDate.day,currDate.weekdayStr];
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",currDate.hour,currDate.minute];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    if(controller == _siginListFetchedResultsController) {//今天的签到数据变了
         Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
        _todaySigInArr = [_userManager getSigInListGuid:employee.employee_guid siginDate:[NSDate date]];
        self.todatSiginNumber.text = [NSString stringWithFormat:@"今日已签到%ld次",_todaySigInArr.count];
        if(_todaySigInArr.count)
            self.tableView.tableFooterView = [UIView new];
        else
            self.tableView.tableFooterView = _noDataView;
        [_tableView reloadData];
        return;
    }
    if(controller == _userFetchedResultsController) {
        User *user = _userManager.user;
        UIImageView *imageView = [_leftNavigationBarButton viewWithTag:1001];
        UILabel *nameLabel = [_leftNavigationBarButton viewWithTag:1002];
        UILabel *companyLabel = [_leftNavigationBarButton viewWithTag:1003];
        [imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        nameLabel.text = user.real_name;
        if([NSString isBlank:user.currCompany.company_name]) {
            companyLabel.text = @"未选择圈子";
            //没有圈子就退出当前界面
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSString *companyName = user.currCompany.company_name;
            if(companyName.length > 8) {
                companyName = [companyName stringByReplacingCharactersInRange:NSMakeRange(8, companyName.length - 8) withString:@"..."];
            }
            companyLabel.text = companyName;
        }
        return;
    }
    if(controller == _employeeFetchedResultsController) {
        //#BANG-187 没有实时获取到权限
        //获取到圈子员工后重新创建右边按钮
        [self setRightNavigationBarItem];
        return;
    }
}
#pragma mark --
#pragma mark -- MAMapViewDelegate
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if(currUserLocation.location.coordinate.longitude == 0) {
        currUserLocation = userLocation;
        //根据位置请求当前位置的POI
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        request.location = [AMapGeoPoint locationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
        /* 按照距离排序. */
        request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
        request.sortrule = 0;
        request.requireExtension = YES;
        request.radius = 300;
        [_search AMapPOIAroundSearch:request];
    }
}
#pragma mark --
#pragma mark -- AMapSearchDelegate
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
        return;
    AMapPOI *searchPOI = response.pois[0];
    self.weatherLabel.text = searchPOI.district;
    //查询天气
    //构造AMapWeatherSearchRequest对象，配置查询参数
    AMapWeatherSearchRequest *request1 = [[AMapWeatherSearchRequest alloc] init];
    //#BANG-524 用adcode来获取天气是最准确的
    request1.city = searchPOI.adcode;
    request1.type = AMapWeatherTypeLive; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气
    //发起行政区划查询
    [_search AMapWeatherSearch:request1];
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    if(error.code == 1806) {
        [self.navigationController.view showFailureTips:@"网络不可用，请连接网络"];
    }
}
#pragma mark --
#pragma mark -- AMapSearchDelegate
//实现天气查询的回调函数
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    if(response.lives.count == 0)
        return;
    AMapLocalWeatherLive *live = response.lives[0];
    NSString *addressAndWeatherStr = [NSString stringWithFormat:@"%@ %@ %@°C",self.weatherLabel.text,live.weather,live.temperature];
    self.weatherLabel.text = addressAndWeatherStr;
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SignIn *sigin = _todaySigInArr[indexPath.row];
    CGFloat height = 95;//没有详情 没有图片的高度
    //算出详情占多高 最宽：屏幕宽度－66
    if(![NSString isBlank:sigin.descriptionStr]) {
        height = height + [[NSString stringWithFormat:@"说明：%@",sigin.descriptionStr] textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 56, 100000)].height + 15;
    } else {
        height = height + [@"说明：无" textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 56, 100000)].height + 15;
    }
    //如果有附件图片
    if(![NSString isBlank:sigin.attachments])
        return height + (MAIN_SCREEN_WIDTH - 56 - 10) / 3.f + 10;
    return height + 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _todaySigInArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SigInListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SigInListCell" forIndexPath:indexPath];
    cell.data = _todaySigInArr[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark -- 
#pragma mark -- SigInListCellDelegate
//图片被点击
- (void)SigInListCellPhotoClicked:(NSArray*)photos {
    PlainPhotoBrose *brose = [PlainPhotoBrose new];
    brose.photoArr = photos;
    brose.index = 0;
    [self.navigationController pushViewController:brose animated:YES];
}
//地址被点击
- (void)SigInListCellAdressClicked:(CLLocationCoordinate2D)cLLocationCoordinate2D {
    ShowAdressController *show = [ShowAdressController new];
    show.cLLocationCoordinate2D = cLLocationCoordinate2D;
    [self.navigationController pushViewController:show animated:YES];
}
#pragma mark --
#pragma mark -- setNavigationBar
- (void)setLeftNavigationBarItem {
    User *user = _userManager.user;
    _leftNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftNavigationBarButton.frame = CGRectMake(15, 25, 100, 38);
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,8, 17)];
    arrowImage.image = [UIImage imageNamed:@"navigationbar_back"];
    arrowImage.frame = CGRectMake(0, 0.5 * (38 - arrowImage.frame.size.height), arrowImage.frame.size.width, arrowImage.frame.size.height);
    [_leftNavigationBarButton addSubview:arrowImage];
    //创建头像
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(arrowImage.frame) + 5, 2, 33, 33)];
    [imageView zy_cornerRadiusRoundingRect];
    imageView.tag = 1001;
    [imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    [_leftNavigationBarButton addSubview:imageView];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(43 + CGRectGetMaxX(arrowImage.frame), 2, 100, 12)];
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.text = user.real_name;
    nameLabel.tag = 1002;
    [_leftNavigationBarButton addSubview:nameLabel];
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(43 + CGRectGetMaxX(arrowImage.frame), 23, 100, 10)];
    companyLabel.font = [UIFont systemFontOfSize:10];
    companyLabel.textColor = [UIColor whiteColor];
    if([NSString isBlank:user.currCompany.company_name])
        companyLabel.text = @"未选择圈子";
    else {
        NSString *companyName = user.currCompany.company_name;
        if(companyName.length > 8) {
            companyName = [companyName stringByReplacingCharactersInRange:NSMakeRange(8, companyName.length - 8) withString:@"..."];
        }
        companyLabel.text = companyName;
    }
    companyLabel.tag = 1003;
    [_leftNavigationBarButton addSubview:companyLabel];
    [_leftNavigationBarButton addTarget:self action:@selector(leftNavigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_leftNavigationBarButton];
}
- (void)leftNavigationBtnClicked:(id)btn {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setRightNavigationBarItem {
    //先删除掉重新创建
    if(_rightBtn) [_rightBtn removeFromSuperview];
    if(_moreSelectView) [_moreSelectView removeFromSuperview];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _rightBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH - 15 - 60, 25, 70, 30);
    _rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:_rightBtn];
    //是不是当前圈子的管理员或者圈主
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    if([_userManager.user.currCompany.admin_user_guid isEqualToString:_userManager.user.user_guid] || employee.is_admin) {
        [_rightBtn addTarget:self action:@selector(rightClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_rightBtn setTitle:@"更多" forState:UIControlStateNormal];
        _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100 - 5, 64 + 5, 100, 45 * 3)];
        _moreSelectView.selectArr = @[@"我的签到",@"签到统计",@"考勤设置"];
        _moreSelectView.delegate = self;
        [_moreSelectView setupUI];
        [self.view addSubview:_moreSelectView];
        [self.view bringSubviewToFront:_moreSelectView];
    } else {
        [_rightBtn setTitle:@"我的签到" forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(siginNote:) forControlEvents:UIControlEventTouchUpInside];
    }
}
//更多被点击
- (void)rightClicked:(UIButton*)item {
    if(_moreSelectView.isHide)
        [_moreSelectView showSelectView];
    else
        [_moreSelectView hideSelectView];
}
#pragma mark -- MoreSelectViewDelegate
-(void)moreSelectIndex:(int)index {
    if(index == 0) {//签到记录
        SiginNoteController *sigin = [SiginNoteController new];
        [self.navigationController pushViewController:sigin animated:YES];
    } else if (index == 1) {//签到统计
        WebNonstandarViewController *webViewcontroller = [[WebNonstandarViewController alloc]init];
        webViewcontroller.applicationUrl  = [NSString stringWithFormat:@"%@PunchCard/SignInStatistics?userGuid=%@&companyNo=%d&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
        [self.navigationController pushViewController:webViewcontroller animated:YES];
    } else {//签到设置
        AttendanceRollController *roll = [AttendanceRollController new];
        [self.navigationController pushViewController:roll animated:YES];
    }
}
//签到记录
- (void)siginNote:(UIBarButtonItem*)item {
    SiginNoteController *sigin = [SiginNoteController new];
    [self.navigationController pushViewController:sigin animated:YES];
}
//计算签到次数
- (void)countSigin {
    @synchronized (self) {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //#BANG-536 用户在不常用圈子签到时提示用户
        //###---检查当前圈子是不是用户经常签到的圈子 begin---###
        if(_userManager.user.currCompany.company_no == 0)
            return;
        //得到用户所有在职的圈子
        NSMutableArray<Company*> *companyArr = [@[] mutableCopy];
        for (Company *company in [_userManager getCompanyArr]) {
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
            if(employee.status == 1 || employee.status == 4) {
                [companyArr addObject:company];
            }
        }
        //用一个数组保存用户在对应圈子签到次数（取前10天的数据上/下班数据）
        NSMutableArray<NSNumber*> *siginNumberArr = [@[] mutableCopy];
        //得到当前的时间
        NSDate *currDate = [NSDate date];
        for (Company *company in companyArr) {
            //当前循环中圈子上/下班的总数
            int count = 0;
            //得到自己在当前圈子中的员工数据
            Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:company.company_no];
            //循环得到前10天的签到信息
            for (int i = 0;i < 10;i ++) {
                NSDate *currLoopDate = [currDate dateByAddingTimeInterval:-1 * (i * 24 * 60 * 60)];
                NSArray<SignIn*> *sigInArr = [_userManager getSigInListGuid:employee.employee_guid siginDate:currLoopDate];
                //只取上/下班数据
                for (SignIn *signIn in sigInArr) {
                    if(signIn.category == 0 || signIn.category == 1) {
                        count ++;
                    }
                }
            }
            //是不是当前用户所在圈子 是就赋值
            if(company.company_no == _userManager.user.currCompany.company_no)
                currCompanySiginCount = count;
            //数组里面加上当前圈子的上/下班次数
            [siginNumberArr addObject:@(count)];
        }
        //找到最多的上/下班次数
        int maxCount = [siginNumberArr[0] intValue];
        for(int i = 1;i < siginNumberArr.count;i ++) {
            if([siginNumberArr[i] intValue] > maxCount)
                maxCount = [siginNumberArr[i] intValue];
        }
        maxCompanySiginCount = maxCount;
    });
    }
}
//签到按钮被点击
- (IBAction)siginClicked:(id)sender {
    //当前没有圈子就退出
    if(_userManager.user.currCompany.company_no == 0) {
        [self.navigationController.view showMessageTips:@"请选择一个圈子后再进行此操作"];
        return;
    }
    //如果还没有计算完成 就返回
    if(maxCompanySiginCount == -1)
        return;
    //判断是不是最多的，然后提示用户
    if(currCompanySiginCount != maxCompanySiginCount) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"是否要在 %@ 签到？",_userManager.user.currCompany.company_name] message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //之后从这个界面操作不需要再提示用户
            currCompanySiginCount = maxCompanySiginCount;
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
            CreateSiginController *sigin = [story instantiateViewControllerWithIdentifier:@"CreateSiginController"];
            [self.navigationController pushViewController:sigin animated:YES];
        }];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alertVC addAction:okAction];
        [alertVC addAction:cancleAction];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    //###---检查当前圈子是不是用户经常签到的圈子 end---###
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"MainStory" bundle:nil];
    CreateSiginController *sigin = [story instantiateViewControllerWithIdentifier:@"CreateSiginController"];
    [self.navigationController pushViewController:sigin animated:YES];
}

@end
