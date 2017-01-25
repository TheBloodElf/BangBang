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
#import "PlainPhotoBrose.h"
#import "OrientationViewController.H"
//之前逻辑：进入后先获取最新的签到规则，然后进行定位，然后根据当前位置获取签到规则中最近的签到点，当签到规则改变时重复上面步骤
//最新逻辑：定位和获取签到规则分开


//获取签到规则+定位 -> 得到最近的签到点 -> 计算当前位置和签到点的距离 -> 设置常用位置/搜索POI
@interface CreateSiginController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SiginImageDelegate,MAMapViewDelegate,AMapSearchDelegate,RBQFetchedResultsControllerDelegate> {
    UserManager *_userManager;//用户管理器
    NSMutableArray *_todaySiginArr;//今天所有的签到记录
    SignIn *_currSignIn;//创建签到的模型
    NSMutableArray<UIImage*> *_siginImageArr;//签到附件数组
    NSMutableArray<NSString*> *_siginImageNameArr;//签到附件名字数组
    
    SiginRuleSet *_currSiginRuleSet;//当前圈子的签到规则 id为-1表示还没有获取到签到规则 id为0表示当前圈子没有签到规则
    PunchCardAddressSetting *_currPunchCardAddressSetting;//离用户最近的规则中的地址
    RBQFetchedResultsController *_siginFetchedResultsController;//签到规则数据监听 用于在无网络切换到有网时改变签到规则
    
    MAUserLocation *currUserLocation;//当前位置，提高定位精准度
    MAMapView *_mapView;//使用地图来定位 更准确
    AMapSearchAPI *_search;//搜索地址
    
    BOOL isFirstLoad;
}

@property (weak, nonatomic) IBOutlet UILabel *siginDeatilLabel;//签到详情的辅助提示
@property (weak, nonatomic) IBOutlet UITextView *siginTextView;//签到详情
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
    _currSiginRuleSet = [SiginRuleSet new];
    _currSiginRuleSet.id = -1;
    _currPunchCardAddressSetting = [PunchCardAddressSetting new];
    _userManager = [UserManager manager];
    _siginImageArr = [@[] mutableCopy];
    _siginImageNameArr = [@[] mutableCopy];
    //得到自己在当前圈子中的信息
    Employee *employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    _siginFetchedResultsController = [_userManager createSiginRuleFetchedResultsController];
    _siginFetchedResultsController.delegate = self;
    //显示当前圈子名字
    self.currCompanyName.text = _userManager.user.currCompany.company_name;
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
    //获取用户今天的所有签到记录
    _todaySiginArr = [_userManager getSigInListGuid:employee.employee_guid siginDate:[NSDate date]];
    _currSignIn = [SignIn new];
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
    //给模型加上一些确认的值
    _currSignIn.employee_guid = employee.employee_guid;
    _currSignIn.create_name = employee.real_name;
    _currSignIn.company_no = _userManager.user.currCompany.company_no;
    self.siginTextView.delegate = self;
    //初始化上班 下班 外勤 其他按钮选中状态
    [self initCategoryBtn];
    //初始化搜索
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    //先把用户位置给获取到
    currUserLocation = [MAUserLocation new];
    //进入页面就获取一次签到规则
    [self getCompanySiginRule];
    //#BANG-465 签到详情限制30字符
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewEditChanged:) name:@"UITextViewTextDidChangeNotification" object:_siginTextView];
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
-(void)textViewEditChanged:(NSNotification *)obj
{
    UITextView *textField = (UITextView *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]){// 简体中文输入
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 30) {
                [self.navigationController.view showMessageTips:@"签到详情大于30个字"];
                textField.text = [toBeString substringToIndex:30];
            }
        }
    } else {// 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if (toBeString.length > 30) {
            [self.navigationController.view showMessageTips:@"签到详情大于30个字"];
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:30];
            if (rangeIndex.length == 1) {
                textField.text = [toBeString substringToIndex:30];
            } else {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 30)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}
#pragma mark --
#pragma mark -- 获取签到规则
- (void)getCompanySiginRule {
    [UserHttp getSiginRule:_userManager.user.currCompany.company_no handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSMutableArray *array = [@[] mutableCopy];
        for (NSDictionary *dic in data) {
            NSMutableDictionary *dicDic = [dic mutableCopy];
            dicDic[@"work_day"] = [dicDic[@"work_day"] componentsJoinedByString:@","];
            SiginRuleSet *set = [SiginRuleSet new];
            [set mj_setKeyValues:dicDic];
            //这里动态添加签到地址
            RLMArray<PunchCardAddressSetting> *settingArr = [[RLMArray<PunchCardAddressSetting> alloc] initWithObjectClassName:@"PunchCardAddressSetting"];
            for (NSDictionary *settingDic in dicDic[@"address_settings"]) {
                PunchCardAddressSetting *setting = [PunchCardAddressSetting new];
                [setting mj_setKeyValues:settingDic];
                [settingArr addObject:setting];
            }
            set.json_list_address_settings = settingArr;
            [array addObject:set];
        }
        [_userManager updateSiginRule:array companyNo:_userManager.user.currCompany.company_no];
    }];
}
#pragma mark -- 
#pragma mark -- RBQFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(nonnull RBQFetchedResultsController *)controller {
    //获取签到规则
    [self getCurrCompanySiginRule];
    [self getCurrSiginAdress];
}
#pragma mark --
#pragma mark -- 得到当前圈子的签到规则
- (void)getCurrCompanySiginRule {
    NSArray<SiginRuleSet*> *siginArr = [_userManager getSiginRule:_userManager.user.currCompany.company_no];
    //#141
    if(siginArr.count)
        _currSiginRuleSet = siginArr[0];
    else
        _currSiginRuleSet = [SiginRuleSet new];
}
#pragma mark --
#pragma mark -- 根据用户当前位置得到最近的签到点信息
//这是一个闭合的地方 因为获取签到规则和定位是异步的，但是他们都会执行到这里
- (void)getCurrSiginAdress {
    //还没有定位成功
    if(currUserLocation.location.coordinate.longitude == 0)
        return;
    //还没有得到圈子规则 圈子规则不存在
    if(_currSiginRuleSet.id == 0 || _currSiginRuleSet.id == -1)
        return;
    //如果已经获取到了位置就返回
    if(_currPunchCardAddressSetting.id != 0)
        return;
    double distance = MAXFLOAT;
    CLLocation *currentLoaction = [[CLLocation alloc] initWithLatitude:currUserLocation.location.coordinate.latitude longitude:currUserLocation.location.coordinate.longitude];
    //算出最近的签到规则地址
    for (PunchCardAddressSetting *model in _currSiginRuleSet.json_list_address_settings) {
        CLLocationDistance distanceFromSettingPoint = [currentLoaction distanceFromLocation:[[CLLocation alloc] initWithLatitude:model.latitude longitude:model.longitude]];
        if (distanceFromSettingPoint < distance) {
            distance = distanceFromSettingPoint;
            _currPunchCardAddressSetting = model;
        }
    }
    //如果当前签到点在范围内 就默认把地图显示在常用签到点位置
    if((_currSignIn.category < 2) && (distance <= _currSiginRuleSet.scope)) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [self setCommenSigninAdress];
        });
    } else {
        //根据位置请求当前位置的POI
        [self getCurrAdressPoi];
    }
}
#pragma mark --
#pragma mark -- 根据当前位置获取周围POI
- (void)getCurrAdressPoi {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:currUserLocation.coordinate.latitude longitude:currUserLocation.coordinate.longitude];
    /* 按照距离排序. */
    request.types = @"汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施";
    request.sortrule = 0;
    request.requireExtension = YES;
    request.radius = 300;
    [_search AMapPOIAroundSearch:request];
}
#pragma mark --
#pragma mark -- 如果当前签到点在范围内 就默认把地图显示在常用签到点位置
- (void)setCommenSigninAdress {
    Employee *owner = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    //取出用户最近10天在当前签到点的签到地址
    NSMutableArray<SignIn*> *signInArr = [@[] mutableCopy];
    NSDate *currDate = [NSDate date];
    for (int i = 0; i < 9; i ++) {
        NSDate *temp = [currDate dateByAddingTimeInterval: - i * 24 * 60 * 60];
        NSArray *array = [_userManager getSigInListGuid:owner.employee_guid siginDate:temp];
        for (SignIn *signIn in array) {
            if([signIn.setting_guid isEqualToString: _currPunchCardAddressSetting.setting_guid]) {
                [signInArr addObject:signIn];
            }
        }
    }
    //没有信息就还是获取当前位置POI
    if(signInArr.count == 0) {
        [self getCurrAdressPoi];
        return;
    }
    //计算出签到点最多的地址 用两个数组来装，一个数组装签到地址（相同经纬度只装一个），对应下标另一个数组装次数
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
    //得到最多的签到点
    SignIn *maxCountSigin = computeSigInArr[index];
    _currSignIn.address = [NSString stringWithFormat:@"%@%@%@%@%@", maxCountSigin.province,maxCountSigin.city,maxCountSigin.subdistrict,maxCountSigin.address,maxCountSigin.address_name];
    _currSignIn.province = maxCountSigin.province;
    _currSignIn.city = maxCountSigin.city;
    _currSignIn.city_code = maxCountSigin.city_code;
    _currSignIn.subdistrict = maxCountSigin.subdistrict;
    _currSignIn.address_name = maxCountSigin.address_name;
    _currSignIn.latitude = maxCountSigin.latitude;
    _currSignIn.longitude = maxCountSigin.longitude;
    //重新获取当前位置地图的缩略图
    dispatch_async(dispatch_get_main_queue(), ^{
       [self setMapImageViewWithLatitude:_currSignIn.latitude longitude:_currSignIn.longitude];
        self.currAdressDetail.text = [NSString stringWithFormat:@"%@%@%@%@", maxCountSigin.province,maxCountSigin.city,maxCountSigin.subdistrict,maxCountSigin.address];
        self.currAdressName.text = _currSignIn.address_name;
    });
}

#pragma mark --
#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //重新选取位置
    if(indexPath.row == 3) {
        //上下班签到，还没有获取到签到规则，不进入选择位置界面 #BANG-520
        if(_currSignIn.category < 2)
            if(_currSiginRuleSet.id == -1)
                return;
        //重新选择位置 可能当前定位不是用户想要的位置
        OrientationViewController *orientation = [OrientationViewController new];
        orientation.currSiginRule = _currSiginRuleSet;
        orientation.category = _currSignIn.category;
        orientation.finishOrientation = ^(AMapPOI *poi){
            if(!poi) return;
            _currSignIn.province = poi.province;
            _currSignIn.city = poi.city;
            _currSignIn.city_code = (int)poi.citycode;
            _currSignIn.subdistrict = poi.district;
            _currSignIn.address_name = poi.name;
            _currSignIn.latitude = poi.location.latitude;
            _currSignIn.longitude = poi.location.longitude;
            _currSignIn.address = [NSString stringWithFormat:@"%@%@%@%@%@", _currSignIn.province,_currSignIn.city,_currSignIn.subdistrict,poi.address,_currSignIn.address_name];
            
            self.currAdressDetail.text = [NSString stringWithFormat:@"%@%@%@%@", _currSignIn.province,_currSignIn.city,_currSignIn.subdistrict,poi.address];
            self.currAdressName.text = _currSignIn.address_name;
            //重新获取当前位置地图的缩略图
            [self setMapImageViewWithLatitude:_currSignIn.latitude longitude:_currSignIn.longitude];
        };
        [self.navigationController pushViewController:orientation animated:YES];
    }
}
#pragma mark --
#pragma mark -- MAMapViewDelegate
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (currUserLocation.location.coordinate.latitude == 0) {
        currUserLocation = userLocation;
        [self getCurrSiginAdress];
    }
}
#pragma mark --
#pragma mark -- AMapSearchDelegate
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0) return;
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
    //获取当前位置 地图的缩略图
    [self setMapImageViewWithLatitude:_currSignIn.latitude longitude:_currSignIn.longitude];
}
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    if(error.code == 1806) {
        [self.navigationController.view showFailureTips:@"网络不可用，请连接网络"];
    }
}
//获取当前位置 地图的缩略图
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
    if(_siginImageArr.count == 3)
        return 3;
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
    //拍照
    if((_siginImageArr.count != 3) && (_siginImageArr.count == indexPath.row)) {
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
    } else {
        //图片预览
        PlainPhotoBrose *brose = [PlainPhotoBrose new];
        NSMutableArray *photoArr = [@[] mutableCopy];
        for (int i = 0; i < _siginImageArr.count; i ++) {
            Photo *photo = [Photo new];
            photo.oiginalImage = _siginImageArr[i];
            [photoArr addObject:photo];
        }
        brose.photoArr = [photoArr copy];
        [self.navigationController pushViewController:brose animated:YES];
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
            [self.navigationController.view showMessageTips:@"你还没有上班！"];
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
    //是否定位
    if(currUserLocation.location.coordinate.longitude == 0) {
        [self.navigationController.view showMessageTips:@"请选择位置"];
        return;
    }
    //判断是否有签到规则
    if(_currSignIn.category < 2) {
        if(_currSiginRuleSet.id == -1) {
            [self.navigationController.view showMessageTips:@"正在获取签到规则"];
            return;
        }
        if(_currSiginRuleSet.id == 0) {
            [self.navigationController.view showMessageTips:@"请管理员在后台设置签到规则"];
            return;
        }
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
    NSArray *workArr = [_currSiginRuleSet.work_day componentsSeparatedByString:@","];
    if (_currSignIn.category < 2 && [workArr containsObject:@([NSDate date].weekday).stringValue]) {
        //判断时间是否迟到或者早退
        NSDate *currDate = [NSDate new];
        NSUInteger currDateSecond = currDate.hour * 60 * 60 + currDate.minute * 60 + currDate.second;
        if(_currSignIn.category == 0) {//上班 得到当前的时间 看是否是迟到超过5分钟 超过了那必须要写详情
            BOOL isArrive = NO;
            NSDate *leaveDate = [NSDate dateWithTimeIntervalSince1970:_currSiginRuleSet.start_work_time / 1000];
            NSUInteger leaveDateSecond = leaveDate.hour * 60 * 60 + leaveDate.minute * 60 + leaveDate.second;
            if (currDateSecond > (leaveDateSecond + 5 * 60)) isArrive = YES;
            _currSignIn.validity = !isArrive;
            if (isArrive && [NSString isBlank:self.siginTextView.text]) {//如果迟到 必须要写详情
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"已超过上班时间请填写原因" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
                [alertVC addAction:alertSure];
                [self presentViewController:alertVC animated:YES completion:nil];
                return;
            }
        }
        if (_currSignIn.category == 1) {//下班 得到当前的时间 看是否是早退 早退要写详情
            BOOL isLeave = NO;
            NSDate *leaveDate = [NSDate dateWithTimeIntervalSince1970:_currSiginRuleSet.end_work_time / 1000];
            NSUInteger leaveDateSecond = leaveDate.hour * 60 * 60 + leaveDate.minute * 60 + leaveDate.second;
            if (currDateSecond < leaveDateSecond) isLeave = YES;
            _currSignIn.validity = !isLeave;
            if (isLeave && [NSString isBlank:self.siginTextView.text]) {//如果早退 需要写明原因
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"还未到下班时间请填写原因" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
                [alertVC addAction:alertSure];
                [self presentViewController:alertVC animated:YES completion:nil];
                return;
            }
        }
    }
    //提交数据
    [self.navigationController.view showLoadingTips:@""];
    _currSignIn.create_on_utc = [[NSDate date] timeIntervalSince1970] * 1000;
    _currSignIn.descriptionStr = _currSignIn.descriptionStr ?: @"";
    _currSignIn.setting_guid = _currSiginRuleSet.setting_guid;
    [UserHttp sigin:_currSignIn handler:^(id data, MError *error) {
        if(error) {
            [self.navigationController.view dismissTips];
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        _currSignIn = [SignIn new];
        [_currSignIn mj_setKeyValues:data];
        _currSignIn.descriptionStr = data[@"description"];
        if(_siginImageArr.count == 0) {
            [self.navigationController.view dismissTips];
            [_userManager addSigin:_currSignIn];
            [self.navigationController popViewControllerAnimated:YES];
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
        [self.navigationController popViewControllerAnimated:YES];
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
