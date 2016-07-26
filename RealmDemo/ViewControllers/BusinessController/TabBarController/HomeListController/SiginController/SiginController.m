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

@interface SiginController ()<MoreSelectViewDelegate,UITableViewDelegate,UITableViewDataSource,RBQFetchedResultsControllerDelegate,CLLocationManagerDelegate,AMapSearchDelegate,SigInListCellDelegate> {
    UIButton *_leftNavigationBarButton;//左边导航的按钮
    UIView *_noDataView;//没有数据的视图
    UserManager *_userManager;//用户管理器
    RBQFetchedResultsController *_userFetchedResultsController;//用户数据库监听
    MoreSelectView *_moreSelectView;//多选视图
    NSMutableArray<SignIn*> *_todaySigInArr;//今天签到的数组
}
@property (weak, nonatomic) IBOutlet UILabel *todatSiginNumber;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) AMapSearchAPI *search;//搜索天气
@property (strong,nonatomic) CLLocationManager *locationManager;//定位获取位置
@end

@implementation SiginController

- (void)viewDidLoad {
    [super viewDidLoad];
    _todaySigInArr = [@[] mutableCopy];
    [self.tableView registerNib:[UINib nibWithNibName:@"SigInListCell" bundle:nil] forCellReuseIdentifier:@"SigInListCell"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _userManager = [UserManager manager];
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    //创建表格视图
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    _todaySigInArr = [_userManager getTodaySigInListGuid:employee.employee_guid];
    _userFetchedResultsController = [_userManager createUserFetchedResultsController];
    _userFetchedResultsController.delegate = self;
    self.todatSiginNumber.text = [NSString stringWithFormat:@"今日已签到%ld次",_todaySigInArr.count];
    _noDataView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, MAIN_SCREEN_WIDTH, 15)];
    label.textColor = [UIColor grayColor];
    label.text = @"你今天还没有签到哦";
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    [_noDataView addSubview:label];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if(_todaySigInArr.count)
        self.tableView.tableFooterView = [UIView new];
    else
        self.tableView.tableFooterView = _noDataView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setLeftNavigationBarItem];
    [self setRightNavigationBarItem];
    //看是否有签到记录数据 没有就从服务器获取
    if(_todaySigInArr.count == 0) {
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
    }
    //使用原生定位
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 100.0f;
    [_locationManager startUpdatingLocation];
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    // Do any additional setup after loading the view from its nib.
}
//一直刷新时间
- (void)updateTime {
    NSDate *currDate = [NSDate date];
    self.dateLabel.text = [NSString stringWithFormat:@"%02ld月%02ld日 %@",currDate.month,currDate.day,currDate.weekdayStr];
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",currDate.hour,currDate.minute];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //导航透明
    [self.navigationController.navigationBar setBackgroundImage:[UIImage colorImg:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:[UIImage colorImg:[UIColor clearColor]]];
    [self.navigationController.navigationBar setShadowImage:[UIImage colorImg:[UIColor clearColor]]];
}
#pragma mark --
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    User *user = controller.fetchedObjects[0];
    UIImageView *imageView = [_leftNavigationBarButton viewWithTag:1001];
    UILabel *nameLabel = [_leftNavigationBarButton viewWithTag:1002];
    UILabel *companyLabel = [_leftNavigationBarButton viewWithTag:1003];
    [imageView sd_setImageWithURL:[NSURL URLWithString:user.currCompany.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    nameLabel.text = user.real_name;
    if([NSString isBlank:user.currCompany.company_name])
        companyLabel.text = @"未选择圈子";
    else
        companyLabel.text = user.currCompany.company_name;
}
#pragma mark -- 
#pragma mark -- CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //得到newLocation 火星坐标转换
    CLLocationCoordinate2D coordinate = [locations[0] coordinate];
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error)
        {
            [_locationManager stopUpdatingLocation];
            CLPlacemark * placemark = [placemarks lastObject];
            NSDictionary *test = [placemark addressDictionary];
            //  Country(国家)  State(城市)  SubLocality(区)
            self.weatherLabel.text = [test objectForKey:@"SubLocality"];
            //查询天气
            //构造AMapWeatherSearchRequest对象，配置查询参数
            AMapWeatherSearchRequest *request = [[AMapWeatherSearchRequest alloc] init];
            request.city = self.weatherLabel.text;
            request.type = AMapWeatherTypeLive; //AMapWeatherTypeLive为实时天气；AMapWeatherTypeForecase为预报天气
            //发起行政区划查询
            [_search AMapWeatherSearch:request];
        }else {
            self.weatherLabel.text = @"定位失败...";
        }
    }];
}
#pragma mark --
#pragma mark -- AMapSearchDelegate
//实现天气查询的回调函数
- (void)onWeatherSearchDone:(AMapWeatherSearchRequest *)request response:(AMapWeatherSearchResponse *)response
{
    //如果是实时天气
    if(request.type == AMapWeatherTypeLive)
    {
        if(response.lives.count == 0)
            return;
        AMapLocalWeatherLive *live = response.lives[0];
        NSString *addressAndWeatherStr = [NSString stringWithFormat:@"%@ %@ %@°C",self.weatherLabel.text,live.weather,live.temperature];
        self.weatherLabel.text = addressAndWeatherStr;
    }
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SignIn *sigin = _todaySigInArr[indexPath.row];
    CGFloat height = 100;//没有详情 没有图片的高度
    //算出详情占多高 最宽：屏幕宽度－66
    if(![NSString isBlank:sigin.descriptionStr]) {
        height = height + [[NSString stringWithFormat:@"说明：%@",sigin.descriptionStr] textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 66, 100000)].height ;
    } else {
        height = height + [@"说明：无" textSizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(MAIN_SCREEN_WIDTH - 66, 100000)].height;
    }
    //如果有附件图片 高度＋95
    if(![NSString isBlank:sigin.attachments])
        height = height + 95;
    return height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _todaySigInArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SigInListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SigInListCell" forIndexPath:indexPath];
    cell.data = _todaySigInArr[indexPath.row];
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
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:brose] animated:YES completion:nil];
}
//地址被点击
- (void)SigInListCellAdressClicked:(CLLocationCoordinate2D)cLLocationCoordinate2D {
    
}
#pragma mark --
#pragma mark -- setNavigationBar
- (void)setLeftNavigationBarItem {
    User *user = _userManager.user;
    _leftNavigationBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftNavigationBarButton.frame = CGRectMake(0, 0, 100, 38);
    //创建头像
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 33, 33)];
    imageView.layer.cornerRadius = 33 / 2.f;
    imageView.clipsToBounds = YES;
    imageView.tag = 1001;
    [imageView sd_setImageWithURL:[NSURL URLWithString:user.currCompany.logo] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    [_leftNavigationBarButton addSubview:imageView];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 2, 100, 12)];
    nameLabel.font = [UIFont systemFontOfSize:12];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.text = user.real_name;
    nameLabel.tag = 1002;
    [_leftNavigationBarButton addSubview:nameLabel];
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 23, 100, 10)];
    companyLabel.font = [UIFont systemFontOfSize:10];
    companyLabel.textColor = [UIColor blackColor];
    if([NSString isBlank:user.currCompany.company_name])
        companyLabel.text = @"未选择圈子";
    else
        companyLabel.text = user.currCompany.company_name;
    companyLabel.tag = 1003;
    [_leftNavigationBarButton addSubview:companyLabel];
    [_leftNavigationBarButton addTarget:self action:@selector(leftNavigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_leftNavigationBarButton];
}
- (void)leftNavigationBtnClicked:(id)btn {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setRightNavigationBarItem {
    //是不是当前圈子的管理员或者创建者
    if([_userManager.user.currCompany.admin_user_guid isEqualToString:_userManager.user.user_guid]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(rightClicked:)];
        _moreSelectView = [[MoreSelectView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH - 100, 64, 100, 120)];
        _moreSelectView.selectArr = @[@"我的签到",@"签到统计",@"签到设置"];
        _moreSelectView.delegate = self;
        [_moreSelectView setupUI];
        [self.view addSubview:_moreSelectView];
        [self.view bringSubviewToFront:_moreSelectView];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"签到记录" style:UIBarButtonItemStylePlain target:self action:@selector(siginNote:)];
    }
}
//更多被点击
- (void)rightClicked:(UIBarButtonItem*)item {
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
        webViewcontroller.applicationUrl  = [NSString stringWithFormat:@"%@PunchCard/SignInStatistics?userGuid=%@&companyNo=%ld&access_token=%@",XYFMobileDomain,_userManager.user.user_guid,_userManager.user.currCompany.company_no,[IdentityManager manager].identity.accessToken];
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
//签到按钮被点击
- (IBAction)siginClicked:(id)sender {
    //看是否有签到规则
    if([_userManager getSiginRule:_userManager.user.currCompany.company_no].count == 0) {
        [self.navigationController.view showMessageTips:@"无法签到，请管理员设置签到规则"];
        return;
    }
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"SiginStory" bundle:nil];
    CreateSiginController *sigin = [story instantiateViewControllerWithIdentifier:@"CreateSiginController"];
    [self.navigationController pushViewController:sigin animated:YES];
}
@end
