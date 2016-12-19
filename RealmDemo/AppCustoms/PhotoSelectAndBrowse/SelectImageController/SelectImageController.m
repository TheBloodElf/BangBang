//
//  SelectImageController.m
//  fadein
//
//  Created by Apple on 16/1/18.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "SelectImageController.h"
#import "SelectImageCollectionCell.h"
#import "PhotoImageCollectionCell.h"
#import "PhotoGroupController.h"


@interface SelectImageController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LoadDataWithGroup,PhotoDidSelect,AllowSelectDelegate,BigPhotoSelectDelegate>
{
    NSMutableArray<Photo*> *_photoArr;
    
    UICollectionView *_photoCollectView;
    
    ALAssetsLibrary *_libary;
    
    UIView *_bottomView;
}
@property (nonatomic, retain) AllowSelectPhotoBrose *allowSelectVC;

@property (nonatomic, retain) BigPhotoSelectController *bigPhotoSelectVC;

@end

@implementation SelectImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _photoArr = [NSMutableArray new];
    _libary = [ALAssetsLibrary new];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadDefulatData];
    [self configPhotoCollectionView];
    [self configBottomView];
    
    self.title = @"相机胶卷";
    [self setupLeftNavigationButton];
    [self setupRightNavigationButton];
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont systemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor blackColor]}];
}

#pragma mark -- BigPhotoSelectDelegate
- (void)bigPhotoSelectReturn
{
    [_photoCollectView reloadData];
    [self setNumber:[self getSelectNumber]];
}

//自己来抛出回调
- (void)bigPhotoSelectFinish:(NSMutableArray<Photo*>*)photoArr
{
    if(self.delegate)
    {
        for (Photo * lo_photo in photoArr) {
            if(lo_photo.oiginalImage)
                lo_photo.oiginalImage = [UIImage imageWithData:[[UIImage imageWithCGImage:[lo_photo.alAsset aspectRatioThumbnail]] dataInNoSacleLimitBytes:MaXPicSize]];
        }
        [self.delegate selectImageFinish:photoArr];
    }
    [self.navigationController setDirection:E_NAVIGATION_DIRECTION_DOWN];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 取消缩略图\原图的持有
- (void)cancleZoOiImage
{
    for (Photo *lo_temp in _photoArr)
    {
        lo_temp.oiginalImage = nil;
    }
}

#pragma mark -- AllowSelectDelegate
- (void) allowSelectReturn
{
    //这里去掉缩略图的持有
    [self cancleZoOiImage];
    [_photoCollectView reloadData];
    [self setNumber:[self getSelectNumber]];
}

//自己来抛出回调
- (void) allowSelectFinish:(NSMutableArray<Photo*> *)allSelecArr
{
    if(self.delegate)
        [self.delegate selectImageFinish:allSelecArr];
    [self.navigationController setDirection:E_NAVIGATION_DIRECTION_DOWN];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 配置底部视图
- (void)configBottomView
{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 44, MAIN_SCREEN_WIDTH, 44)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    //左边的标签宽高
    CGFloat labelWidth = 20;
    CGFloat labelHeight = 20;
    //右边按钮的宽高  距离右边的距离
    CGFloat btnWidth = 50;
    CGFloat btnHeight = 30;
    CGFloat btnRight = 5;
    
    //创建按钮
    UIButton *okBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"完成" forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    okBtn.tag = 1102;
    [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(finishBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    okBtn.frame = CGRectMake(_bottomView.frame.size.width - btnWidth - btnRight, 0.5 * (_bottomView.frame.size.height - btnHeight), btnWidth, btnHeight);
    [_bottomView addSubview:okBtn];
    
    //创建标签后面的红色图像
    UIView *iamgeView = [[UIView alloc] initWithFrame:CGRectMake(_bottomView.frame.size.width - btnWidth - labelWidth - btnRight, 0.5 * (_bottomView.frame.size.height - labelHeight), labelWidth, labelHeight)];
    iamgeView.tag = 1101;
    iamgeView.backgroundColor = [UIColor blackColor];
    iamgeView.layer.cornerRadius = labelHeight / 2;
    iamgeView.clipsToBounds = YES;
    [_bottomView addSubview:iamgeView];
    
    //创建数字标签
    //算出数字的宽高 相对于图像的上 左边距
    CGFloat numberLabelHeight =  9;
    CGFloat numberLabelWidth = labelHeight  / 1.5;
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelWidth - numberLabelWidth) / 2,0.5 * (labelHeight - numberLabelHeight), numberLabelWidth, numberLabelHeight)];
    numberLabel.tag = 1100;
    numberLabel.textColor = [UIColor whiteColor];
    numberLabel.backgroundColor = [UIColor clearColor];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.font = [UIFont systemFontOfSize:12];
    
    [iamgeView addSubview:numberLabel];
    [self.view addSubview:_bottomView];
    
    
    //创建左边的预览按钮
    UIButton *lookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lookBtn setTitle:@"预览" forState:UIControlStateNormal];
    lookBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    lookBtn.frame = CGRectMake(btnRight,  0.5 * (_bottomView.frame.size.height - btnHeight), btnWidth, btnHeight);
    [lookBtn addTarget:self action:@selector(lookBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [lookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    lookBtn.tag = 1099;
    [_bottomView addSubview:lookBtn];
}
- (void)finishBtnClicked:(UIButton*)btn {
    if(self.delegate)
        [self.delegate selectImageFinish:[self getAllSelectImage]];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)lookBtnClicked:(UIButton*)btn {
    self.allowSelectVC = [AllowSelectPhotoBrose new];
    self.allowSelectVC.photoArr = [self getAllSelectImage];
    self.allowSelectVC.delegate = self;
    [self.navigationController pushViewController:self.allowSelectVC animated:YES];
}
#pragma mark -- 获取所有被选中的图片

- (NSMutableArray *)getAllSelectImage
{
    NSMutableArray *tempArr = [NSMutableArray new];
    for (Photo * tempPhoto in _photoArr) {
        if(tempPhoto.selected) {
            //这里加载原图
            if(!tempPhoto.oiginalImage) {
                tempPhoto.oiginalImage = [UIImage imageWithData:[[UIImage imageWithCGImage:[tempPhoto.alAsset aspectRatioThumbnail]] dataInNoSacleLimitBytes:MaXPicSize]];
            }
            [tempArr addObject:tempPhoto];
        }
    }
    return tempArr;
}

#pragma mark -- 显示最初的数据
- (void)loadDefulatData
{
    [_libary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        //便利完成了
        if(group == nil) {
            dispatch_main_async_safe(^(){
                [_photoCollectView reloadData];
            });
             *stop = YES;
        }
        else {
            NSString *currstr = [group valueForProperty:@"ALAssetsGroupPropertyName"];
            if([currstr isEqualToString:@"相机胶卷"] || [currstr isEqualToString:@"Camera Roll"]) {
                [self getPhotoWithGroup:group];
                group = nil;
                *stop = YES;
            }
        }
        
    } failureBlock:^(NSError *error) {}];
}

- (void)getPhotoWithGroup:(ALAssetsGroup*)group
{
    //重新加载数据
    [self setNumber:0];
    NSMutableArray *tempArr = [NSMutableArray new];
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result == nil && index == NSNotFound) {
            dispatch_main_async_safe(^(){
                _photoArr = tempArr;
                [_photoCollectView reloadData];
            });
            *stop = YES;
        }
        else {
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            if([type isEqualToString:ALAssetTypePhoto]) {
                Photo *photo = [Photo new];
                photo.selected = NO;
                photo.index = (int)index;
                photo.alAsset = result;
                [tempArr addObject:photo];
            }
        }
    }];
}

#pragma mark -- 配置集合视图
- (void)configPhotoCollectionView
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake((MAIN_SCREEN_WIDTH - 4) / 3.f, (MAIN_SCREEN_WIDTH - 4) / 3.f);
    _photoCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 44) collectionViewLayout:layout];
    _photoCollectView.backgroundColor = [UIColor whiteColor];
    _photoCollectView.delegate = self;
    _photoCollectView.dataSource = self;
    _photoCollectView.alwaysBounceVertical = YES;
    [_photoCollectView registerNib:[UINib nibWithNibName:@"SelectImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"SelectImageCollectionCell"];
    [_photoCollectView registerNib:[UINib nibWithNibName:@"PhotoImageCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"PhotoImageCollectionCell"];
    [self.view addSubview:_photoCollectView];
}

#pragma mark -- UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

#pragma mark -- UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_showCameraCell) {
        return _photoArr.count + 1;
    }
    else{
        return _photoArr.count;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //显示图像的cell
    PhotoImageCollectionCell *imageCell = [_photoCollectView dequeueReusableCellWithReuseIdentifier:@"PhotoImageCollectionCell" forIndexPath:indexPath];
    
    if (indexPath.item == 0 && _showCameraCell) {
        [imageCell setupCameraCell:[UIImage imageNamed:@"selectImagePicker"]];
        
        imageCell.delegate = nil;
    }
    else{
        NSInteger cellIndexOffset = 0;
        if (_showCameraCell) {
            cellIndexOffset = 1;
        }
        
        Photo *lo_photo = _photoArr[(indexPath.item-cellIndexOffset)];
        imageCell.data = lo_photo;
        
        if(!imageCell.delegate)
            imageCell.delegate = self;
    }

   
    return imageCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0 && _showCameraCell) {
        WeakSelf(weakSelf);
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(selectCameraReturn)]) {
                [weakSelf.delegate selectCameraReturn];
            }
            
        }];
    }
    else{
        BigPhotoSelectController *big = [BigPhotoSelectController new];
        big.index = (int)indexPath.row;
        big.photoArr = _photoArr;
        big.maxCount = self.maxSelect;
        big.delegate = self;
        [self.navigationController pushViewController:big animated:YES];
    }
}

#pragma mark -- PhotoDidSelect
- (void)photoDidSelect:(Photo *)photo
{
    NSInteger cellIndexOffset = 0;
    if (_showCameraCell) {
        cellIndexOffset = 1;
    }
    
    NSUInteger selectPhotoIndex = [_photoArr indexOfObject:photo];
    
    if(photo.selected == YES)
    {
        photo.selected = NO;
        [_photoCollectView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectPhotoIndex+cellIndexOffset inSection:0]]];
    }
    else
    {
        if([self getSelectNumber] + 1 <= self.maxSelect)
        {
            photo.selected = YES;
            [_photoCollectView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:selectPhotoIndex+cellIndexOffset inSection:0]]];
        }
        else
        {
            [self showAlertView];
        }
    }
    [self setNumber:[self getSelectNumber]];
}

#pragma mark -- LoadPhotoWithArr

- (void)loadDataWithGroup:(ALAssetsGroup *)photoGroup
{
    [self getPhotoWithGroup:photoGroup];
}

#pragma mark -- 获取被选中的数量

- (int)getSelectNumber
{
    int count = 0;
    for (Photo *tempPhoto in _photoArr) {
        if(tempPhoto.selected == YES)
            count ++;
    }
    return count;
}

#pragma mark -- 设置被选中的数量

- (void)setNumber:(int)number
{
    UIButton *okBtn = [_bottomView viewWithTag:1102];
    UIView *iamgeView = [_bottomView viewWithTag:1101];
    UIButton *lookBtn = [_bottomView viewWithTag:1099];
    UILabel *numberLabel = [_bottomView viewWithTag:1100];
    
    if(number)
    {
        numberLabel.text = [NSString stringWithFormat:@"%d",number];
        okBtn.enabled = YES;
        lookBtn.enabled = YES;
        iamgeView.hidden = NO;
        [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [lookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else
    {
        okBtn.enabled = NO;
        lookBtn.enabled = NO;
        iamgeView.hidden = YES;
        [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [lookBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}



#pragma mark -- 弹出已经达到上限

- (void)showAlertView
{
    [self.navigationController showFailureTips:@"已达到选择上限"];
}



#pragma mark -
#pragma mark - Navigation Config

#pragma mark -- Navigation buttons

- (void)setupLeftNavigationButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(leftNavigationButtonAction:)];
}

- (void)setupRightNavigationButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightNavigationButtonAction:)];
}

#pragma mark -- Navigation Actions

- (void)goGroupController {
    PhotoGroupController *vc = [PhotoGroupController new];
    vc.delegate = self;
    vc.data = _libary;
    [self.navigationController setDirection:E_NAVIGATION_DIRECTION_LEFT];
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark -
#pragma mark - Button Actions

- (void)leftNavigationButtonAction:(id)sender {
    [self goGroupController];
}

- (void)rightNavigationButtonAction:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
