//
//  ImageScrollView.m
//  fadein
//
//  Created by Apple on 16/1/6.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "ImageScrollView.h"
#import "ShowBigImageScroller.h"
#define ImageViewTag 1000

@interface ImageScrollView  ()<UIScrollViewDelegate>
{
    NSTimer *_timer;
}
@property (nonatomic, retain) NSArray<Photo*> *photoArr;

@end

@implementation ImageScrollView
{
    UIScrollView *_scrollView;
    int currIndex;
}
- (void)configUI
{
    currIndex = 0;
    if(_scrollView)
        [_scrollView removeFromSuperview];
    //启动定时器
    if(!_timer)
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(time) userInfo:nil repeats:YES];
    [self layoutIfNeeded];
    //创建滚动视图
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = _scrollView.showsHorizontalScrollIndicator = NO;
    //加载图片
    for (int i = 0; i < self.photoArr.count; i ++) {
        ShowBigImageScroller *imageView = [[ShowBigImageScroller alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
        imageView.noNeedScale = YES;
        imageView.noNeedOption = YES;
        imageView.photo = self.photoArr[i];
        imageView.tag = ImageViewTag +i;
        [_scrollView addSubview:imageView];
    }
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(self.photoArr.count * _scrollView.frame.size.width, _scrollView.frame.size.height);
    [self showIndex:currIndex];
    [self addSubview:_scrollView];
}

- (void)dataDidChange
{
    self.photoArr = self.data;
    [self configUI];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    currIndex = scrollView.contentOffset.x / MAIN_SCREEN_WIDTH;
    [self showIndex:currIndex];
}

- (void)showAtIndex:(int)index
{
    ShowBigImageScroller *centerImageView = [_scrollView viewWithTag:index + ImageViewTag];
    [centerImageView setupUI];
}

- (void)showIndex:(int)index
{
    if(self.scrollToIndex)
        self.scrollToIndex(index);
    [self showAtIndex:index];
    if(index - 1 >= 0)
        [self showAtIndex:index - 1];
    if(index + 1 <= self.photoArr.count - 1)
        [self showAtIndex:index + 1];
}

- (void)time
{
    currIndex ++ ;
    if(currIndex == self.photoArr.count)
        currIndex = 0;
    [self showIndex:currIndex];
    [_scrollView setContentOffset:CGPointMake(currIndex * _scrollView.frame.size.width, 0) animated:YES];
}


@end
