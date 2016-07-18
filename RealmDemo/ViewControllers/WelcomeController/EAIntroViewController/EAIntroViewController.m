//
//  EAIntroViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/12.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "EAIntroViewController.h"

@interface EAIntroViewController ()<UIScrollViewDelegate> {
    UIScrollView *_pageScrollView;//展示图片的滚动视图
    UIPageControl *_pageControl;//下面的页面指示器
}
@end

@implementation EAIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //滚动视图每个图片的宽、高
    CGFloat pageScrollImagewidth = self.view.bounds.size.width;
    CGFloat pageScrollImageheight = self.view.bounds.size.height;
    //得到图片名字数组
    NSArray<NSString*> *nameArr = @[@"ic_welcome_avatar_0_0",@"ic_welcome_avatar_1_1",@"ic_welcome_avatar_2_2",@"ic_welcome_avatar_3_3"];
    _pageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, pageScrollImagewidth, pageScrollImageheight)];
    _pageScrollView.contentSize = CGSizeMake(nameArr.count * pageScrollImagewidth, pageScrollImageheight);
    _pageScrollView.showsVerticalScrollIndicator = NO;
    _pageScrollView.showsHorizontalScrollIndicator = NO;
    _pageScrollView.pagingEnabled = YES;
    _pageScrollView.delegate = self;
    [self.view addSubview:_pageScrollView];
    //加入图片
    for (int index = 0; index < nameArr.count; index ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(index * pageScrollImagewidth, 0, pageScrollImagewidth, pageScrollImageheight)];
        imageView.image = [UIImage imageNamed:nameArr[index]];
        [_pageScrollView addSubview:imageView];
    }
    //创建页面指示器
    CGFloat pageControlHeight = 20;
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, pageScrollImageheight - 50 - pageControlHeight, pageScrollImagewidth, pageControlHeight)];
    _pageControl.numberOfPages = nameArr.count;
    _pageControl.currentPage = 0;
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    [self.view addSubview:_pageControl];
    //创建跳过按钮
    UIButton *jumpBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [jumpBtn setTitle:@"跳过" forState:UIControlStateNormal];
    [jumpBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    jumpBtn.frame = CGRectMake(pageScrollImagewidth - 40 - 20, pageScrollImageheight - 20 - 50, 40, 20);
    [self.view addSubview:jumpBtn];
    [jumpBtn addTarget:self action:@selector(jumpClicked:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark -- 
#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //得到当前的偏移量
    CGFloat scrollX = scrollView.contentOffset.x;
    _pageControl.currentPage = (scrollX + scrollView.frame.size.width / 2.f) / scrollView.frame.size.width;
}
- (void)jumpClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(eAIntroViewDidFinish:)]) {
        [self.delegate eAIntroViewDidFinish:self];
    }
}
@end
