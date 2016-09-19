//
//  CreateSiginController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/22.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CreateSiginController.h"
#import "UserManager.h"
#import "UserHttp.h"
#import "SiginImageCell.h"
#import "SiginSelectCell.h"
#import "OrientationViewController.H"

@interface CreateSiginController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SiginImageDelegate,MAMapViewDelegate,AMapSearchDelegate> {
    UserManager *_userManager;//用户管理器
    NSMutableArray *_todaySiginArr;//今天所有的签到记录
    SignIn *_currSignIn;//创建签到的模型
    NSMutableArray<UIImage*> *_siginImageArr;//签到附件数组
    NSMutableArray<NSString*> *_siginImageNameArr;//签到附件名字数组
    
    SiginRuleSet *_currSiginRuleSet;//当前圈子的签到规则
    PunchCardAddressSetting *_currPunchCardAddressSetting;//离用户最近的规则中的地址
    
    MAUserLocation *currUserLocation;//当前位置，提高定位精准度
    MAMapView *_mapView;//使用地图来定位 更准确
    AMapSearchAPI *_search;//搜索地址
    
    BOOL isFirstLoad;
}

@property (weak, nonatomic) IBOutlet UILabel *siginDeatilLabel;//签到详情的辅助提示
@property (weak, nonatomic) IBOutlet UITextView *siginTextView;//签到详情视图
@property (weak, nonatomic) IBOutlet UIButton *upWorkBtn;//上班
@property (weak, nonatomic) IBOutlet UIButton *downWorkBtn;//下班
@property (weak, nonatomic) IBOutlet UIButton *outWorkBtn;//外勤
@property (weak, nonatomic) IBOutlet UIButton *otherWorkBtn;//其他
@property (weak, nonatomic) IBOutlet UICollectionView *siginImageCollection;//签到图像
@property (weak, nonatomic) IBOutlet UIImageView *currAdressImage;//当前位置图像
@property (weak, nonatomic) IBOutlet UILabel *currAdressName;//当前地址名字
@property (weak, nonatomic) IBOutlet UILabel *currAdressDetail;//当前地址详情
@property (weak, nonatomic) IBOutlet UILabel *currCompanyName;//当前圈子名字
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@end

@implementation CreateSiginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建签到";
    self.upWorkBtn.layer.cornerRadius = 5;
    self.upWorkBtn.clipsToBounds = YES;
    self.downWorkBtn.layer.cornerRadius = 5;
    self.downWorkBtn.clipsToBounds = YES;
    self.outWorkBtn.layer.cornerRadius = 5;
    self.outWorkBtn.clipsToBounds = YES;
    self.otherWorkBtn.layer.cornerRadius = 5;
    self.otherWorkBtn.clipsToBounds = YES;
    self.submitBtn.clipsToBounds = YES;
    self.submitBtn.layer.cornerRadius = 25.f;
    _userManager = [UserManager manager];
    _siginImageArr = [@[] mutableCopy];
    _siginImageNameArr = [@[] mutableCopy];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor siginColor];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //是不是第一次加载这个页面
    if(isFirstLoad) return;
    isFirstLoad = YES;
    
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    //获取签到规则
    _currSiginRuleSet = [_userManager getSiginRule:_userManager.user.currCompany.company_no][0];
    self.tableView.tableFooterView = [UIView new];
    //初始化集合视图
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(73, 73);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    self.siginImageCollection.collectionViewLayout = layout;
    self.siginImageCollection.delegate = self;
    self.siginImageCollection.dataSource = self;
    [self.siginImageCollection registerNib:[UINib nibWithNibName:@"SiginImageCell" bundle:nil] forCellWithReuseIdentifier:@"SiginImageCell"];
    [self.siginImageCollection registerNib:[UINib nibWithNibName:@"SiginSelectCell" bundle:nil] forCellWithReuseIdentifier:@"SiginSelectCell"];
    self.currCompanyName.text = _userManager.user.currCompany.company_name;
    //获取用户今天的所有签到记录
    _todaySiginArr = [_userManager getTodaySigInListGuid:employee.employee_guid];
    _currSignIn = [SignIn new];
    //给模型加上一些确认的值
    _currSignIn.employee_guid = employee.employee_guid;
    _currSignIn.create_name = employee.real_name;
    _currSignIn.company_no = _userManager.user.currCompany.company_no;
    self.siginTextView.delegate = self;
    [self initCategoryBtn];
    //开始定位 然后获取离用户最近的签到地址
    //地图初始化
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _mapView.delegate = self;
    _mapView.hidden = YES;
    _mapView.zoomLevel = 13;//地图缩放级别
    _mapView.distanceFilter = 100;
    _mapView.rotateEnabled = NO;
    _mapView.showsUserLocation = YES;
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    [self.view addSubview:_mapView];
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
}
#pragma mark -- 
#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 3) {//重新定位
        OrientationViewController *orientation = [OrientationViewController new];
        orientation.currSiginRule = _currSiginRuleSet;
        orientation.setting = _currPunchCardAddressSetting;
        orientation.category = _currSignIn.category;
        orientation.finishOrientation = ^(AMapPOI *poi){
            if(!poi)
                return ;
            self.currAdressDetail.text = [NSString stringWithFormat:@"%@%@%@%@", poi.province,poi.city,poi.district,poi.address];
            self.currAdressName.text = poi.name;
            _currSignIn.province = poi.province;
            _currSignIn.city = poi.city;
            _currSignIn.city_code = (int)poi.citycode;
            _currSignIn.subdistrict = poi.district;
            _currSignIn.address = [NSString stringWithFormat:@"%@%@%@%@%@", poi.province,poi.city,poi.district,poi.address,poi.name];
            _currSignIn.address_name = poi.name;
            _currSignIn.latitude = poi.location.latitude;
            _currSignIn.longitude = poi.location.longitude;
            [self setMapImageViewWithLatitude:_currSignIn.latitude longitude:_currSignIn.longitude];
        };
        [self.navigationController pushViewController:orientation animated:YES];
    }
}
#pragma mark --
#pragma mark -- MAMapViewDelegate
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
    NSString *adress = [NSString stringWithFormat:@"%@%@%@%@", searchPOI.province,searchPOI.city,searchPOI.district,searchPOI.address];
    self.currAdressDetail.text = adress;
    self.currAdressName.text = searchPOI.name;
    _currSignIn.province = searchPOI.province;
    _currSignIn.city = searchPOI.city;
    _currSignIn.city_code = (int)searchPOI.citycode;
    _currSignIn.subdistrict = adress;
    _currSignIn.address = adress;
    _currSignIn.address_name = searchPOI.name;
    _currSignIn.latitude = searchPOI.location.latitude;
    _currSignIn.longitude = searchPOI.location.longitude;
    [self setMapImageViewWithLatitude:_currSignIn.latitude longitude:_currSignIn.longitude];
    double distance = MAXFLOAT;
    CLLocation *currentLoaction = [[CLLocation alloc] initWithLatitude:searchPOI.location.latitude longitude:searchPOI.location.longitude];
    //算出最近的签到规则地址
    for (PunchCardAddressSetting *model in _currSiginRuleSet.json_list_address_settings) {
        CLLocationDistance distanceFromSettingPoint = [currentLoaction distanceFromLocation:[[CLLocation alloc] initWithLatitude:model.latitude longitude:model.longitude]];
        if (distanceFromSettingPoint < distance) {
            distance = distanceFromSettingPoint;
            _currPunchCardAddressSetting = model;
        }
    }
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    if(error.code == 1806) {
        [self.navigationController.view showFailureTips:@"网络不可用，请连接网络"];
    }
}
- (void)setMapImageViewWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    NSString *imageUrl = [NSString stringWithFormat:@"http://restapi.amap.com/v3/staticmap?location=%f,%f&zoom=15&size=300*300&markers=mid,,A:%f,%f&key=ee95e52bf08006f63fd29bcfbcf21df0",longitude,latitude,longitude,latitude];
    [self.currAdressImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"signin_position"]];
}
#pragma mark --
#pragma mark -- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    _currSignIn.descriptionStr = textView.text;
    if([NSString isBlank:textView.text])
        self.siginDeatilLabel.hidden = NO;
    else
        self.siginDeatilLabel.hidden = YES;
}
#pragma mark --
#pragma mark -- UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_siginImageArr.count == 3) {
        return 3;
    }
    return _siginImageArr.count + 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if(_siginImageArr.count == 3) {//展示图片
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SiginImageCell" forIndexPath:indexPath];
        SiginImageCell *sigin = (id)cell;
        sigin.delegate = self;
        sigin.data = _siginImageArr[indexPath.row];
    } else {
        if(indexPath.row == _siginImageArr.count) {//选择图片
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SiginSelectCell" forIndexPath:indexPath];
        } else {//展示图片
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SiginImageCell" forIndexPath:indexPath];
            SiginImageCell *sigin = (id)cell;
            sigin.delegate = self;
            sigin.data = _siginImageArr[indexPath.row];
        }
    }
    return cell;
}
#pragma mark --
#pragma mark -- SiginImageDelegate
- (void)SiginImageDelete:(UIImage *)image {
    [_siginImageArr removeObject:image];
    [self.siginImageCollection reloadData];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if(_siginImageArr.count == 3) { } else {
        if(_siginImageArr.count == indexPath.row) {//拍照
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {//看当前设备是否能够拍照
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:picker animated:YES completion:nil];
            } else {
                [self.navigationController.view showFailureTips:@"无法打开相机"];
            }
        }
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    [_siginImageArr addObject:image];
    [self.siginImageCollection reloadData];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//签到类型被点击
- (IBAction)workCategoryClicked:(UIButton*)sender {
    if(sender.tag == 1001) {//如果是点击下班按钮，但是没有上班，需要提醒用户
        if(![self todayHaveUpWork]) {
            [self.navigationController.view showMessageTips:@"你好没有上班！"];
            return;
        }
    }
    //更换签到模型，改变按钮颜色
    if(self.upWorkBtn.enabled == YES) {
        self.upWorkBtn.backgroundColor = [UIColor whiteColor];
        [self.upWorkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if(self.downWorkBtn.enabled == YES) {
        self.downWorkBtn.backgroundColor = [UIColor whiteColor];
        [self.downWorkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if(self.outWorkBtn.enabled == YES) {
        self.outWorkBtn.backgroundColor = [UIColor whiteColor];
        [self.outWorkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if(self.otherWorkBtn.enabled == YES) {
        self.otherWorkBtn.backgroundColor = [UIColor whiteColor];
        [self.otherWorkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    sender.backgroundColor = [UIColor siginColor];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _currSignIn.category = (int)sender.tag - 1000;
}
#pragma mark -- 提交签到数据
//提交按钮被点击
- (IBAction)submitClicked:(id)sender {
     Employee * employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    _currSignIn.employee_guid = employee.employee_guid;
    //是否定位
    if([NSString isBlank:_currSignIn.address]) {
        [self.navigationController.view showMessageTips:@"请选择位置"];
        return;
    }
    //判断距离
    if (_currSignIn.category < 2) {
        //判断当前选择位置是否在圈内
        CGFloat distance = MAMetersBetweenMapPoints(MAMapPointForCoordinate(CLLocationCoordinate2DMake(_currPunchCardAddressSetting.latitude, _currPunchCardAddressSetting.longitude)),MAMapPointForCoordinate(CLLocationCoordinate2DMake(_currSignIn.latitude, _currSignIn.longitude)));
        if(distance > _currSiginRuleSet.scope){
            [self.navigationController.view showMessageTips:@"当前离签到点太远"];
            return;
        }
        _currSignIn.distance = distance;
        _currSignIn.setting_guid = _currPunchCardAddressSetting.setting_guid;
    }
    //判断上下班提醒
    [self checkUpDownWorkAlert];
    //提交签到数据
    [self siginMethod];
}
//判断上下班提醒
- (void)checkUpDownWorkAlert {
    //判断时间是否迟到或者早退
    NSDate *currDate = [NSDate new];
    NSUInteger currDateSecond = currDate.hour * 60 * 60 + currDate.minute * 60 + currDate.second;
    if(_currSignIn.category == 0) {
        //得到当前的时间 看是否是迟到超过5分钟 超过了那必须要写详情
        BOOL isArrive = NO;
        NSDate *leaveDate = [NSDate dateWithTimeIntervalSince1970:_currSiginRuleSet.start_work_time / 1000];
        NSUInteger leaveDateSecond = leaveDate.hour * 60 * 60 + leaveDate.minute * 60 + leaveDate.second;
        if (currDateSecond > (leaveDateSecond + 5 * 60)) {
            isArrive = YES;
        }
        if (isArrive) {//如果迟到 必须要写详情
            if([NSString isBlank:self.siginTextView.text]) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"你迟到超过5分钟，需要写明原因" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
                [alertVC addAction:alertSure];
                [self presentViewController:alertVC animated:YES completion:nil];
            } else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"你已经迟到超过5分钟，确认上班？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    _currSignIn.validity = NO;
                    [self siginMethod];
                }];
                [alertVC addAction:alertCancel];
                [alertVC addAction:alertSure];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        } else {//没有迟到，正常逻辑
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认上班？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                _currSignIn.validity = YES;
                [self siginMethod];
            }];
            [alertVC addAction:alertCancel];
            [alertVC addAction:alertSure];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    } else if (_currSignIn.category == 1) {
        //得到当前的时间 看是否是早退 早退要写详情
        BOOL isLeave = NO;
        NSDate *leaveDate = [NSDate dateWithTimeIntervalSince1970:_currSiginRuleSet.end_work_time / 1000];
        NSUInteger leaveDateSecond = leaveDate.hour * 60 * 60 + leaveDate.minute * 60 + leaveDate.second;
        if (currDateSecond < leaveDateSecond) {
            isLeave = YES;
        }
        if (isLeave) {//如果早退 需要写明原因
            if([NSString isBlank:self.siginTextView.text]) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"你属于早退，需要写明原因" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
                [alertVC addAction:alertSure];
                [self presentViewController:alertVC animated:YES completion:nil];
            } else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"你属于早退，确认下班？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    _currSignIn.validity = NO;
                    [self siginMethod];
                }];
                [alertVC addAction:alertCancel];
                [alertVC addAction:alertSure];
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        } else {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认下班？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                _currSignIn.validity = YES;
                [self siginMethod];
            }];
            [alertVC addAction:alertCancel];
            [alertVC addAction:alertSure];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }
}
//统一一个签到方法 还要上传图片 很是蛋疼
- (void)siginMethod {
    [self.navigationController.view showLoadingTips:@""];
    _currSignIn.create_on_utc = [[NSDate date] timeIntervalSince1970] * 1000;
    _currSignIn.descriptionStr = _currSignIn.descriptionStr ?: @"";
    [UserHttp sigin:_currSignIn handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        _currSignIn = [[SignIn alloc] initWithJSONDictionary:data];
        _currSignIn.descriptionStr = data[@"description"];
        if(_siginImageArr.count == 0) {
            [self.navigationController.view dismissTips];
            [_userManager addSigin:_currSignIn];
            [self.navigationController.view showSuccessTips:@"签到成功"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            //进入上传图片逻辑
            _siginImageNameArr = [@[] mutableCopy];
            [self sendSiginPhoto];
        }
    }];
}
//上传图片
- (void)sendSiginPhoto {
    if(_siginImageNameArr.count == _siginImageArr.count) {
        [self.navigationController.view dismissTips];
        _currSignIn.attachments = [_siginImageNameArr componentsJoinedByString:@","];
        [_userManager addSigin:_currSignIn];
        [self.navigationController.view showSuccessTips:@"签到成功"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        //上传图片
        [UserHttp uploadSiginPic:_siginImageArr[_siginImageNameArr.count] siginId:_currSignIn.id userGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
            if(error) {
                [self.navigationController.view dismissTips];
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            [_siginImageNameArr addObject:data[@"data"][@"file_url"]];
            [self sendSiginPhoto];
        }];
    }
}
#pragma mark --
#pragma mark -- UITableViewDelegate
//初始化上下班按钮状态
- (void)initCategoryBtn {
    //如果上班过了，上班按钮变灰不可用
    if([self todayHaveUpWork]) {
        self.upWorkBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.upWorkBtn.enabled = NO;
        [self.upWorkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if([self todayHaveDownWork]) {//如果下班过了，下班按钮变灰不可用
            self.downWorkBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
            self.downWorkBtn.enabled = NO;
            [self.downWorkBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //默认选中外勤按钮
            self.outWorkBtn.backgroundColor = [UIColor siginColor];
            [self.outWorkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _currSignIn.category = 2;
        } else {//默认选中下班按钮
            self.downWorkBtn.backgroundColor = [UIColor siginColor];
            [self.downWorkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _currSignIn.category = 1;
        }
    } else {//默认选中上班按钮
        _currSignIn.category = 0;
        self.upWorkBtn.backgroundColor = [UIColor siginColor];
        [self.upWorkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}
//是否上班
- (BOOL)todayHaveUpWork {
    for (SignIn *sigin in _todaySiginArr)
        if(sigin.category == 0)
            return YES;
    return NO;
}
//是否下班
- (BOOL)todayHaveDownWork {
    for (SignIn *sigin in _todaySiginArr)
        if(sigin.category == 1)
            return YES;
    return NO;
}
@end
