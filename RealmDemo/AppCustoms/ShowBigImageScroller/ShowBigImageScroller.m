//
//  ShowBigImageScroller.m
//  fadein
//
//  Created by Apple on 16/1/15.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "ShowBigImageScroller.h"
#import "UIImageView+WebCache.h"

@interface ShowBigImageScroller  ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
{
    //初始化一个图像视图
    UIImageView *imageView;
    
    //是不是双击事件
    BOOL isBothTouch;
    
    //是否已经配置过界面了
    BOOL isLoaded;
}
@property (nonatomic, assign) CGPoint point;
@end

@implementation ShowBigImageScroller


#pragma mark -- init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        if(!imageView) {
            imageView = [UIImageView new];
            [self addSubview:imageView];
        }
    }
    return self;
}

#pragma mark -- 开始配置界面

- (void)setupUI
{
    self.zoomScale = 1;
    //如果已经配置过了  或者正在配置  就不执行
    if(isLoaded) return;
    //设置图像
    imageView.image = self.photo.oiginalImage;
    //如果存在缩放位置就进行动画  否者跳过此步骤
    CGRect finishRect;
    //图像应该被放置的位置
    if(self.noNeedScale) {
        finishRect = self.bounds;
        imageView.frame = finishRect;
    } else {
        if(self.photo.oiginalImage)
            finishRect = [self scaleToScreenSize:self.photo.oiginalImage.size];
        else {
            [self showLoadingTips:@""];//没有原图就从网上获取
            finishRect = CGRectZero;
        }
    }
    
    //判断是否有初始化位置  有就在它的基础上进行  没有就直接中间显示
    if(!CGRectEqualToRect(self.photo.fromRect, CGRectZero)) {
        //如有有目标位置
        if(!CGRectEqualToRect(finishRect, CGRectZero))
        {
            //缩放动画的时间
            CGFloat scaleTime = 0.3;
            
            imageView.frame = self.photo.fromRect;
            [UIView animateWithDuration:scaleTime animations:^{
                imageView.frame = finishRect;
            }];
        }
    } else {
        if(!CGRectEqualToRect(finishRect, CGRectZero))
            imageView.frame = finishRect;
    }
    
    [self addOpreation];
    
    //如果有原图  就直接展示  不需要加载
    if(self.photo.oiginalImage) {
        //配置已经加载
        isLoaded = YES;
    } else {
        //下载原图
        [imageView sd_setImageWithURL:self.photo.oiginalUrl placeholderImage:[UIImage imageNamed:@"default_image_icon"] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.photo.oiginalImage = image;
            imageView.image = self.photo.oiginalImage;
            //配置已经加载
            isLoaded = YES;
            if(!self.noNeedScale)
                imageView.frame = [self scaleToScreenSize:self.photo.oiginalImage.size];
            [self dismissTips];
        }];
    }
}
#pragma mark -- 清除图像，重新加载
- (void)reset
{
    isLoaded = NO;
    imageView.image = nil;
}

#pragma mark -- 获取用户点击的位置
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.allObjects.firstObject;
    self.point = [touch locationInView:imageView];
}

#pragma  mark -- 给自己加上一些必要的手势
- (void)addOpreation
{
    self.contentSize = imageView.frame.size;
    [self setMinimumZoomScale:1];
    [self setMaximumZoomScale:5];
    // 设置UIScrollView初始化缩放级别
    [self setZoomScale:1];
    //添加长按手势
    imageView.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPGR:)];
    [imageView addGestureRecognizer:lpgr];
    lpgr.delegate = self;
    //添加单击手势
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(danJi:)];
    [imageView addGestureRecognizer:tgr];
    //添加双击手势
    UITapGestureRecognizer *tggr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shuangJi:)];
    tggr.delegate = self;
    [imageView setMultipleTouchEnabled:YES];
    tggr.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:tggr];
    //这行很关键，意思是只有当没有检测到tggr 或者 检测doubleTapGestureRecognizer失败，tgr才有效
    [tgr requireGestureRecognizerToFail:tggr];
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
}
- (void)danJi:(UITapGestureRecognizer*)tgr {
    if(self.clickedBlock)
    {//如果存在缩放到的目标位置  就进行缩放  否者 直接调用被点击事件
        if(!CGRectEqualToRect(self.photo.toRect, CGRectZero))
            [self loadAnimation];
        else {
            if(self.clickedBlock)
                self.clickedBlock();
        }
    }
}
- (void)shuangJi:(UITapGestureRecognizer*)tggr {
    //在这里放大图片视图
    //这里有点问题，当图像的宽度小于屏幕的宽度时会出问题
    isBothTouch = YES;
    [UIView animateWithDuration:0.5 animations:^{
        //让点击的位置居中
        if(self.zoomScale == 1){[self setZoomScale:3];}
        else {[self setZoomScale:1];}
    }];
}
- (void)loadAnimation
{
    WeakSelf(weakSelf)
    [UIView animateWithDuration:0.02 animations:^{
        [weakSelf setZoomScale:1];
        imageView.frame = [self scaleToScreenSize:imageView.frame.size];//这两句话时一样的效果
    } completion:^(BOOL finished) {
        [UIView  animateWithDuration:0.3 animations:^{
            imageView.frame = weakSelf.photo.toRect;
        } completion:^(BOOL finished) {
            if(weakSelf.clickedBlock)
                weakSelf.clickedBlock();
        }];
    }];
}

#pragma  mark -- 获取图像根据屏幕缩放后的尺寸

- (CGRect)scaleToScreenSize:(CGSize)mSize
{
    CGFloat main_width = self.frame.size.width;
    CGFloat mian_height = self.frame.size.height;
    //对图像进行处理
    CGSize size = mSize;
    CGFloat height = size.height;
    CGFloat width = size.width;
    //判把宽度设置成屏幕的宽度
    if(width != main_width) {
//        if(width > main_width)
        {
            //缩放到屏幕的宽度，并且高度按比例缩
            height = height * main_width / width;
            width = main_width;
        }
    }
    if(height > mian_height) {
        //如果高度大于屏幕的高度，就把高度缩小至屏幕的高度，并且宽度按比例缩小
        width = width * mian_height / height;
        height = mian_height;
    }
    //得到放大后应该显示的范围
    return  CGRectMake(0.5 * (main_width - width), 0.5 * (mian_height - height), width, height);
}


#pragma  mark -- 返回自身子视图中能够缩放的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

#pragma mark -- 加了这句话就可以避免缩放问题了
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                   scrollView.contentSize.height * 0.5 + offsetY);
    //是不是双击事件  是的话把点击的位置居中显示
    if(isBothTouch && self.zoomScale != 1) {
        //这里＊0.618的目的是为了避免放大后超出offset的范围，看着就是边框了
        self.contentOffset = CGPointMake(self.zoomScale * 0.618 * self.point.x,self.zoomScale * 0.618 * self.point.y);
        isBothTouch = NO;
    }
    
}
#pragma mark -- 长按手势
- (void)longPGR:(UILongPressGestureRecognizer*)lpgr
{
    if(lpgr.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到相册", nil];
        [action showInView:self];
    }
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        UIImageWriteToSavedPhotosAlbum(self.photo.oiginalImage, nil, nil, nil);
        [self showMessageTips:@"保存成功"];
    }
}
@end
