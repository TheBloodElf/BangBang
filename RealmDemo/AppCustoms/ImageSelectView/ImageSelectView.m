//
//  ImageSelectView.m
//  fadein
//
//  Created by Apple on 16/1/4.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "ImageSelectView.h"
#import "ImageCollectionViewCell.h"
#import "SelectImageViewCell.h"
#import "AllowDeletePhotoBrose.h"


#import "SelectImageController.h"

static NSString *selectImageIdentifier = @"selectImageIdentifier";
static NSString *painlImageIdentifier = @"painlImageIdentifier";

@interface ImageSelectView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UINavigationControllerDelegate, UIImagePickerControllerDelegate,SelectImageDelegate,AllowDeleteDelegate>
{
    UICollectionView *colloctView;//集合视图显示图像
}

@end

@implementation ImageSelectView


- (void)configUI
{
    if(!self.photoArr)
    {
        self.photoArr = [NSMutableArray new];
    }
    //创建集合视图
    UICollectionViewFlowLayout  *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake((self.frame.size.width - 27) / 4, (self.frame.size.width - 27) / 4);
    colloctView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    colloctView.backgroundColor = [UIColor whiteColor];
    colloctView.delegate = self;
    colloctView.dataSource = self;
    [colloctView registerClass:NSClassFromString(@"SelectImageViewCell") forCellWithReuseIdentifier:selectImageIdentifier];
    [colloctView registerClass:NSClassFromString(@"ImageCollectionViewCell") forCellWithReuseIdentifier:painlImageIdentifier];
    [self addSubview:colloctView];
    
    [self updateHeight];
}

- (void)setPhotoArr:(NSMutableArray<Photo *> *)photoArr
{
    _photoArr = photoArr;
    [self updateHeight];
}
//配置每个集合视图对象
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(self.photoArr.count != self.maxCount && indexPath.row == self.photoArr.count)
    {
        SelectImageViewCell *cell = [colloctView dequeueReusableCellWithReuseIdentifier:selectImageIdentifier forIndexPath:indexPath];
        WeakSelf(weakSelf)
        cell.selectImage = ^(){[weakSelf pritofe];};
        return cell;
    }
    
   ImageCollectionViewCell  *lo_cell = [colloctView dequeueReusableCellWithReuseIdentifier:painlImageIdentifier forIndexPath:indexPath];
    Photo *lo_photo = self.photoArr[indexPath.row];
    lo_cell.data = lo_photo;
    return lo_cell;
}

#pragma mark -- 弹出照片选择

- (void)pritofe
{
    WeakSelf(weakSelf)
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *cream = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
        picker.delegate = weakSelf;
        picker.sourceType = sourceType;
        [weakSelf.presentController presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *select = [UIAlertAction actionWithTitle:@"选择照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        SelectImageController *selectVC = [SelectImageController new];
        selectVC.maxSelect = weakSelf.maxCount - weakSelf.photoArr.count;
        selectVC.delegate = weakSelf;
        selectVC.showCameraCell = YES;
        [weakSelf.presentController presentViewController:[[UINavigationController alloc] initWithRootViewController:selectVC] animated:YES completion:nil];
    }];
    [alertVC addAction:cancle];
    [alertVC addAction:select];
    [alertVC addAction:cream];
    [self.presentController presentViewController:alertVC animated:YES completion:nil];
}

#pragma mark -- AllowDeleteDelegate

- (void)allowDeleteSelect:(NSArray<Photo*>*)photoArr
{
    self.photoArr = [NSMutableArray arrayWithArray:photoArr];
    [colloctView reloadData];
    [self updateHeight];
}



#pragma mark -- SelectImageDelegate

- (void)selectImageReturn
{
    
}

- (void)selectCameraReturn{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];//初始化
    picker.delegate = self;
    picker.sourceType = sourceType;
    [self.presentController presentViewController:picker animated:YES completion:nil];
}

- (void)selectImageFinish:(NSMutableArray<Photo*>*)photoArr
{
    [self.photoArr addObjectsFromArray:photoArr];
    [colloctView reloadData];
    [self updateHeight];
}


#pragma mark -
#pragma mark - Image Picker Controller Delegate
//返回选取的图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    Photo *photo = [Photo new];
    photo.oiginalImage = [UIImage imageWithData:[image dataInNoSacleLimitBytes:MaXPicSize]];
    photo.zoomImage = [photo.oiginalImage scaleToSize:CGSizeMake(210, 0.0f)];
    [picker dismissViewControllerAnimated:YES completion:^{}];
    [self.photoArr addObject:photo];
    [colloctView reloadData];
    [self updateHeight];
}

// 取消选取时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AllowDeletePhotoBrose *brow = [AllowDeletePhotoBrose new];
    brow.photoArr = self.photoArr;
    brow.index = indexPath.row;
    brow.delegate = self;
    brow.hideDeleteBar = NO;
    [self.presentController.navigationController pushViewController:brow animated:YES];
}

//在这里把自己视图的高度抛出去
- (void)updateHeight
{
    float allHeight = [self calHeightWithImagesCount:self.photoArr.count];
    colloctView.frame = CGRectMake(0, 0, self.frame.size.width, allHeight);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, allHeight);
    
    if(self.heightChange)
    {
       self.heightChange(allHeight);
    }
}

//根据图片个数计算整体高度
- (float)calHeightWithImagesCount:(NSInteger)imageCount
{
    int count;
    if(imageCount != self.maxCount)
    {
        count = imageCount + 1;
    }
    else
    {
        count = self.maxCount;
    }
    CGFloat height = (self.frame.size.width - 27) / 4;
    CGFloat allHeight;
    if(count % 4 == 0)
    {
        allHeight = (count / 4) * height + (count / 4 - 1) * 9;
    }
    else
    {
        allHeight = (count / 4 + 1) * height + count / 4 * 9;
    }
    return allHeight;
}

//返回集合视图的cell个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.photoArr.count != self.maxCount)
        return self.photoArr.count + 1;
    return self.maxCount;
}
//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}
//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}
@end
