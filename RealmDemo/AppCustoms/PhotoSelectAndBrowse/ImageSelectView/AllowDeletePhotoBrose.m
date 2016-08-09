//
//  BorewViewController.m
//  图片浏览控件
//
//  Created by Apple on 15/12/8.
//  Copyright © 2015年 Apple. All rights reserved.
//

#import "AllowDeletePhotoBrose.h"
#import "Photo.h"
#import "ShowBigImageScroller.h"

#define ImageViewTag 10000

@interface AllowDeletePhotoBrose ()<UIScrollViewDelegate>
{
    UIScrollView *scrollView;//滚动视图
    
    int currIndex;//当前显示的是第几张
    
    UILabel *numberLabel;//上方显示第几张图片的标签
    
    
    UIToolbar *toolBar;
}
@end

@implementation AllowDeletePhotoBrose

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, 1)];
    [self.view addSubview:view];
    [self configUI];
    [self scrollToIndex:self.index];
    
    currIndex = self.index;
    
    numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    numberLabel.font = [UIFont systemFontOfSize:20];
    numberLabel.textAlignment = NSTextAlignmentCenter;
    numberLabel.text = [NSString stringWithFormat:@"%d/%ld",self.index + 1,(unsigned long)self.photoArr.count];
    self.navigationItem.titleView = numberLabel;
    
    if (!_hideDeleteBar) {
        //创建右边的删除按钮
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, MAIN_SCREEN_HEIGHT - 44, MAIN_SCREEN_WIDTH, 44)];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(showSheet)];
        [toolBar setTintColor:[UIColor redColor]];
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        toolBar.items = @[spaceItem,barItem];
        [self.view addSubview:toolBar];
        [self.view bringSubviewToFront:toolBar];
        [self setupLeftNavigationButton];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%@ viewWillAppear", NSStringFromClass([self class]));
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(allowDeleteSelect:)])
    {
        [self.delegate allowDeleteSelect:self.photoArr];
    }
}
//配置ui环境
- (void)configUI
{
    //配置自定义的滚动视图
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    for (int index = 0;index < self.photoArr.count;index ++) {
        ShowBigImageScroller *scView = [[ShowBigImageScroller alloc] initWithFrame:CGRectMake(index * MAIN_SCREEN_WIDTH,0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
        scView.photo = self.photoArr[index];
        scView.tag = ImageViewTag + index;
        WeakSelf(weakSelf)
        scView.clickedBlock = ^()
        {
            //当点击图片的时候  我们显示或者隐藏导航条和底部的工具条
            [weakSelf.navigationController setNavigationBarHidden:!self.navigationController.navigationBar.hidden animated:YES];
            [toolBar setHidden:!toolBar.hidden];
        };
        [scrollView addSubview:scView];
    }
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(self.photoArr.count * MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT);
    [self.view addSubview:scrollView];
    [self.view bringSubviewToFront:toolBar];
}

- (void)showSheet
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"你确定要将此照片在所有设备中删除吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"删除照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         [self delete];
    }];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)delete
{
    [self.photoArr removeObjectAtIndex:currIndex];
    if(currIndex == 0)
    {
        if(self.photoArr.count == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [scrollView removeFromSuperview];
            [self configUI];
            [self scrollToIndex:currIndex];
            numberLabel.text = [NSString stringWithFormat:@"1/%ld",(unsigned long)self.photoArr.count];
        }
    }
    else
    {
        currIndex -- ;
        [scrollView removeFromSuperview];
        [self configUI];
        [self scrollToIndex:currIndex];
        numberLabel.text = [NSString stringWithFormat:@"%d/%ld",currIndex + 1,(unsigned long)self.photoArr.count];
    }
}

//滚动到指定下标位置
- (void)scrollToIndex:(int)index
{
    scrollView.contentOffset = CGPointMake(index * MAIN_SCREEN_WIDTH, 0);
    currIndex = index;
    [self loadAtIndex:index];
}

//当滚动视图减速时加载左右的内容（优化部分）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollVie
{
    int index = scrollView.contentOffset.x / MAIN_SCREEN_WIDTH;
    [self loadAtIndex:index];
    currIndex = index;
    numberLabel.text = [NSString stringWithFormat:@"%d/%ld",currIndex + 1,(unsigned long)self.photoArr.count];
}
- (void)loadAtIndex:(int)index
{
    ShowBigImageScroller *view = (id)[scrollView viewWithTag:index + ImageViewTag];
    [view setupUI];
    if(index - 1 >= 0)
    {
        ShowBigImageScroller *view = (id)[scrollView viewWithTag:index + ImageViewTag - 1];
        [view setupUI];
    }
    if(index + 1 <= self.photoArr.count - 1)
    {
        ShowBigImageScroller *view = (id)[scrollView viewWithTag:index + ImageViewTag + 1];
        [view setupUI];
    }
}

#pragma mark -- Navigation buttons

- (void)setupLeftNavigationButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 40.0f)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0.0f, -15.0f, 0.0f, 0.0f)];
    [button setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(leftNavigationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem = temporaryBarButtonItem;
}
- (void)popBackViewController {
    if(self.delegate && [self.delegate respondsToSelector:@selector(allowDeleteSelect:)])
        [self.delegate allowDeleteSelect:self.photoArr];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark - Button Actions

- (void)leftNavigationButtonAction:(id)sender {
    [self popBackViewController];
}
@end
