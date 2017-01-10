//
//  AllowSelectPhotoBrose.m
//  fadein
//
//  Created by Apple on 16/1/16.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "AllowSelectPhotoBrose.h"

#import "ShowBigImageScroller.h"

#define ImageScrollViewTag 2000

@interface AllowSelectPhotoBrose ()<UIScrollViewDelegate>
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

@implementation AllowSelectPhotoBrose


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self configScrollView];
    [self configScrollViewData];
    [self configBottomView];
    [self scrollToIndex:0];
    
    
    [self setupLeftNavigationButton];
    [self setupRightNavigationButton];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
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
    [okBtn addTarget:self action:@selector(finishClicked:) forControlEvents:UIControlEventTouchUpInside];
    okBtn.frame = CGRectMake(_bottomView.frame.size.width - btnWidth - btnRight, 0.5 * (_bottomView.frame.size.height - btnHeight), btnWidth, btnHeight);
    [_bottomView addSubview:okBtn];
    
    //创建标签后面的红色图像
    UIView *iamgeView = [[UIView alloc] initWithFrame:CGRectMake(_bottomView.frame.size.width - btnWidth - labelWidth - btnRight, 0.5 * (_bottomView.frame.size.height - labelHeight), labelWidth, labelHeight)];
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
    numberLabel.text = [NSString stringWithFormat:@"%ld",(unsigned long)self.photoArr.count];
    [iamgeView addSubview:numberLabel];
    
    [self.view addSubview:_bottomView];

}
- (void)finishClicked:(UIButton*)btn {
    if(self.delegate)
        [self.delegate allowSelectFinish:[self getAllSelectImage]];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark -- 获取所有被选中的图片

- (NSMutableArray *)getAllSelectImage
{
    NSMutableArray *tempArr = [NSMutableArray new];
    for (Photo * tempPhoto in _photoArr) {
        if(tempPhoto.selected)
            [tempArr addObject:tempPhoto];
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
}

#pragma  mark -- 配置该下标的视图　
- (void)setupIndex:(int)idnex
{
    ShowBigImageScroller *sc = [_scrollView viewWithTag:ImageScrollViewTag + idnex];
    [sc setupUI];
}

#pragma mark -
#pragma mark - Navigation Config

#pragma mark -- Navigation Bar

- (void)setupNavigationBar {
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [navigationBar setShadowImage:nil];
}

#pragma mark -- Navigation buttons

- (void)setupLeftNavigationButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftNavigationButtonAction:)];
}

- (void)setupRightNavigationButton {
    rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 40.0f)];
    [rightBarButton setImage:[[UIImage imageNamed:@"btn_select_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [rightBarButton setImage:[[UIImage imageNamed:@"singleNoSelect"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    rightBarButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -35);
    rightBarButton.selected = YES;
    rightBarButton.tag  = 1001;
    rightBarButton.backgroundColor = [UIColor clearColor];
    [rightBarButton addTarget:self action:@selector(rightNavigationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
}

#pragma mark -- Navigation Actions

- (void)popBackViewController {
   
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark - Button Actions

- (void)leftNavigationButtonAction:(id)sender {
    if(self.delegate)
        [self.delegate allowSelectReturn];
    [self popBackViewController];
}

- (void)rightNavigationButtonAction:(UIButton*)sender {
    sender.selected = !sender.selected;
    
    self.photoArr[_currIndex].selected = sender.selected;
    
    
    UILabel *numberLabel = [_bottomView viewWithTag:1100];
    UIView *iamgeView = [_bottomView viewWithTag:1101];
    
    
    if(sender.selected)
    {
        iamgeView.hidden = NO;
        numberLabel.text = [NSString stringWithFormat:@"%d",[numberLabel.text intValue] + 1];
    }
    else
    {
        numberLabel.text = [NSString stringWithFormat:@"%d",[numberLabel.text intValue] - 1];
        //判断是否需要隐藏
        if([numberLabel.text isEqualToString:@"0"])
            iamgeView.hidden = YES;
        else
            iamgeView.hidden = NO;
    }
}

@end
