//
//  PlainPhotoBrose.m
//  fadein
//
//  Created by Apple on 16/1/16.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "PlainPhotoBrose.h"
#import "ShowBigImageScroller.h"

#define ImageScrollViewTag 2000

@interface PlainPhotoBrose ()<UIScrollViewDelegate>
{
    //图像滚动视图
    UIScrollView *_scrollView;
}
@end

@implementation PlainPhotoBrose

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self configScrollView];
    [self configScrollViewData];
    [self scrollToIndex:self.index];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // Do any additional setup after loading the view.
}
#pragma mark -- 配置滚动视图

- (void)configScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    _scrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH * self.photoArr.count, MAIN_SCREEN_HEIGHT);
    _scrollView.showsVerticalScrollIndicator = _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
}
#pragma mark -- 配置滚动视图数据

- (void)configScrollViewData
{
    for (int i = 0; i < self.photoArr.count; i ++) {
        ShowBigImageScroller *sc = [[ShowBigImageScroller alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
        sc.photo = self.photoArr[i];
        sc.tag = ImageScrollViewTag + i;
        WeakSelf(weakSelf)
        sc.clickedBlock = ^()
        {
            [weakSelf.navigationController popViewControllerAnimated:NO];
        };
        [_scrollView addSubview:sc];
    }
}


#pragma  mark -- 滚动视图位置改变的回调

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollToIndex:scrollView.contentOffset.x / scrollView.frame.size.width];
}

#pragma mark -- 根据滑动的下标进行导航条的设置

- (void)scrollToIndex:(int)idnex
{
    _scrollView.contentOffset = CGPointMake(idnex * _scrollView.frame.size.width, 0);
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

@end
