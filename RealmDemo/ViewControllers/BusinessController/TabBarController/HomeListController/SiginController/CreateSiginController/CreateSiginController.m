//
//  CreateSiginController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/22.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CreateSiginController.h"
#import "UserManager.h"
#import "SiginImageCell.h"
#import "SiginSelectCell.h"

@interface CreateSiginController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,SiginImageDelegate> {
    UserManager *_userManager;//用户管理器
    NSMutableArray *_todaySiginArr;//今天所有的签到记录
    SignIn *_currSignIn;//创建签到的模型
    NSMutableArray<UIImage*> *_siginImageArr;//签到附件数组
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

@end

@implementation CreateSiginController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"创建签到";
    _userManager = [UserManager manager];
    _siginImageArr = [@[] mutableCopy];
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
    Employee * employee = [_userManager getEmployeeWithGuid:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no];
    _todaySiginArr = [_userManager getTodaySigInListGuid:employee.employee_guid];
    [self initCategoryBtn];
    _currSignIn = [SignIn new];
    //给模型加上一些确认的值
    _currSignIn.employee_guid = employee.employee_guid;
    _currSignIn.create_name = employee.real_name;
    self.siginTextView.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackIndicatorTransitionMaskImage:nil];
    [self.navigationController.navigationBar setShadowImage:nil];
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
    [_siginImageArr delete:image];
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
            [self presentViewController:picker animated:YES completion:nil];
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
    sender.backgroundColor = [UIColor blackColor];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _currSignIn.category = sender.tag - 1000;
}
//提交按钮被点击
- (IBAction)submitClicked:(id)sender {
    
}
#pragma mark --
#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//初始化上下班按钮状态
- (void)initCategoryBtn {
    //如果上班过了，上班按钮变灰不可用
    if([self todayHaveUpWork]) {
        self.upWorkBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.upWorkBtn.enabled = NO;
        if([self todayHaveDownWork]) {//如果下班过了，下班按钮变灰不可用
            self.downWorkBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
            self.downWorkBtn.enabled = NO;
            //默认选中外勤按钮
            self.outWorkBtn.backgroundColor = [UIColor blackColor];
            [self.outWorkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _currSignIn.category = 2;
        } else {//默认选中下班按钮
            self.downWorkBtn.backgroundColor = [UIColor blackColor];
            [self.downWorkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _currSignIn.category = 1;
        }
    } else {//默认选中上班按钮
        _currSignIn.category = 0;
        self.upWorkBtn.backgroundColor = [UIColor blackColor];
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
