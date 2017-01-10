//
//  BigPhotoSelectController.m
//  fadein
//
//  Created by Apple on 16/1/19.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "BigPhotoSelectController.h"

#import "ShowBigImageScroller.h"


#import "SelectImageController.h"

#define ImageScrollViewTag 2000


@interface BigPhotoSelectController ()<UIScrollViewDelegate>
{
    //当前显示的下标
    int _currIndex;
    //图像滚动视图
    UIScrollView *_scrollView;
    //底部的完成条视图
    UIView *_bottomView;
    //导航右边的按钮
    UIButton *rightBarButton;
}


@end

@implementation BigPhotoSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self configScrollView];
    [self configScrollViewData];
    [self configBottomView];
    
    [self setupLeftNavigationButton];
    [self setupRightNavigationButton];
    [self scrollToIndex:self.index];
   
    [self setNumber:[self getSelectNumber]];
    // Do any additional setup after loading the view.
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
#pragma mark -- 配置底部视图
- (void)configBottomView
{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 44, MAIN_SCREEN_WIDTH, 44)];
    _bottomView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //左边的标签宽高
    CGFloat labelWidth = 20;
    CGFloat labelHeight = 20;
    //右边按钮的宽高  距离右边的距离
    CGFloat btnWidth = 50;
    CGFloat btnHeight = 30;
    CGFloat btnRight = 5;
    
    //创建按钮
    UIButton *okBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"完成" forState:UIControlStateNormal];\
    okBtn.tag = 1102;
    [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(finishBtn:) forControlEvents:UIControlEventTouchUpInside];
    okBtn.frame = CGRectMake(_bottomView.frame.size.width - btnWidth - btnRight, 0.5 * (_bottomView.frame.size.height - btnHeight), btnWidth, btnHeight);
    [_bottomView addSubview:okBtn];
    
    //创建标签后面的红色图像
    UIView *iamgeView = [[UIView alloc] initWithFrame:CGRectMake(_bottomView.frame.size.width - btnWidth - labelWidth - 2 * btnRight, 0.5 * (_bottomView.frame.size.height - labelHeight), labelWidth, labelHeight)];
    iamgeView.tag = 1101;
    iamgeView.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
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
    
}
- (void)finishBtn:(UIButton*)btn {
    if(self.delegate)
        [self.delegate bigPhotoSelectFinish:[self getAllSelectImage]];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- 获取所有被选中的图片

- (NSMutableArray *)getAllSelectImage
{
    NSMutableArray *tempArr = [NSMutableArray new];
    for (Photo * tempPhoto in self.photoArr) {
        if(tempPhoto.selected)
        {
            //这里加载原图
            if(!tempPhoto.oiginalImage)
            {
                tempPhoto.oiginalImage = [UIImage imageWithData:[[UIImage imageWithCGImage:[tempPhoto.alAsset aspectRatioThumbnail]] dataInNoSacleLimitBytes:MaXPicSize]];
                
            }
            
            [tempArr addObject:tempPhoto];
        }
    }
    if(tempArr.count == 0)
        [tempArr addObject:self.photoArr[_currIndex]];
    return tempArr;
}

#pragma  mark -- 滚动视图位置改变的回调

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollToIndex:scrollView.contentOffset.x / scrollView.frame.size.width];
}

#pragma mark -- 配置滚动视图数据

- (void)configScrollViewData
{
    for (int i = 0; i < self.photoArr.count; i ++) {
        ShowBigImageScroller *sc = [[ShowBigImageScroller alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
        sc.photo = self.photoArr[i];
        WeakSelf(weakSelf)
        sc.clickedBlock = ^()
        {
            if(weakSelf.navigationController.navigationBar.hidden == YES)
            {
                [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
                _bottomView.hidden = NO;
            }
            else
            {
                [weakSelf.navigationController setNavigationBarHidden:YES animated:YES];
                _bottomView.hidden = YES;
            }
        };
        sc.tag = ImageScrollViewTag + i;
        [_scrollView addSubview:sc];
    }
}

#pragma mark -- 配置滚动视图

- (void)configScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    _scrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH * self.photoArr.count, MAIN_SCREEN_HEIGHT - 44);
    _scrollView.showsVerticalScrollIndicator = _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    _scrollView.delegate = self;
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * self.index, 0) animated:YES];
}


#pragma mark -- 根据滑动的下标进行导航条的设置

- (void)scrollToIndex:(int)idnex
{
    _currIndex = idnex;
    if([self.photoArr[idnex] selected])
        rightBarButton.selected = YES;
    else
        rightBarButton.selected = NO;
    
    [self setupIndex:idnex];
    
    if(idnex - 1 >= 0)
        [self setupIndex:idnex - 1];
    if(idnex + 1 <= self.photoArr.count - 1)
        [self setupIndex:idnex + 1];
    
    //去掉左边第二个和右边第二个的缩略图持有
    //同时把滚动视图的图像去掉
    if(idnex - 2 >= 0)
    {
        self.photoArr[idnex - 2].oiginalImage = nil;
        ShowBigImageScroller *sc = [_scrollView viewWithTag:ImageScrollViewTag + idnex - 2];
        [sc reset];
    }
    if(idnex + 2 <= self.photoArr.count - 1)
    {
        self.photoArr[idnex + 2].oiginalImage = nil;
        ShowBigImageScroller *sc = [_scrollView viewWithTag:ImageScrollViewTag + idnex + 2];
        [sc reset];
    }
}



#pragma  mark -- 配置该下标的视图
- (void)setupIndex:(int)idnex
{
    //这里加载原图
    if(!self.photoArr[idnex].oiginalImage)
        self.photoArr[idnex].oiginalImage = [UIImage imageWithData:[[UIImage imageWithCGImage:[self.photoArr[idnex].alAsset aspectRatioThumbnail]] dataInNoSacleLimitBytes:MaXPicSize]];
    ShowBigImageScroller *sc = [_scrollView viewWithTag:ImageScrollViewTag + idnex];
    [sc setupUI];
}



#pragma mark -
#pragma mark - Navigation Config

#pragma mark -- Navigation Bar


#pragma mark -- Navigation buttons

- (void)setupLeftNavigationButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftNavigationButtonAction:)];
}

- (void)setupRightNavigationButton {
    rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 40.0f)];
    [rightBarButton setImage:[[UIImage imageNamed:@"btn_select_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [rightBarButton setImage:[[UIImage imageNamed:@"singleNoSelect"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    rightBarButton.tag  = 1001;
    [rightBarButton addTarget:self action:@selector(rightNavigationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
}

#pragma mark -- Navigation Actions

- (void)popBackViewController {
    if(self.delegate && [self.delegate respondsToSelector:@selector(bigPhotoSelectReturn)])
        [self.delegate bigPhotoSelectReturn];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark - Button Actions

- (void)leftNavigationButtonAction:(id)sender {
    [self popBackViewController];
}

#pragma mark -- 设置数量

- (void)setNumber:(int)number
{
    UILabel *numberLabel = [_bottomView viewWithTag:1100];
    UIView *iamgeView = [_bottomView viewWithTag:1101];
    numberLabel.text = [NSString stringWithFormat:@"%d",number];
    if(number == 0)
    {
        iamgeView.hidden = YES;
    }
    else
    {
        iamgeView.hidden = NO;
    }
}

- (void)rightNavigationButtonAction:(UIButton*)sender {
    sender.selected = !sender.selected;
    if(sender.selected)
    {
        if([self getSelectNumber] + 1 <= self.maxCount)
        {
            [self setNumber:[self getSelectNumber] + 1];
        }
        else
        {
            sender.selected = NO;
            [self showAlertView];
        }
    }
    else
        [self setNumber:[self getSelectNumber] - 1];
    self.photoArr[_currIndex].selected = sender.selected;
}

#pragma mark -- 弹出已经达到上限

- (void)showAlertView
{
    [self.navigationController showMessageTips:@"已达到选择上限"];
}

@end
