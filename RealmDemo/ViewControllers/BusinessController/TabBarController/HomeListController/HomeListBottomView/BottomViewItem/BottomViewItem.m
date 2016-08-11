//
//  BottomViewItem.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "BottomViewItem.h"

@interface BottomViewItem () {
    UIImageView *_centerImageView;
    UILabel *_bottomLabel;
}

@end

@implementation BottomViewItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //创建图像
        _centerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        [self addSubview:_centerImageView];
        //创建标签
        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 5 - 12, frame.size.width, 12)];
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_bottomLabel];
        //给右边和下边创建线条
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - 1, 0, 1, frame.size.height)];
        rightView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:rightView];
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
        bottomView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:bottomView];
        //创建全局的按钮
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    return self;
}
//个人日程 团队任务被点击
- (void)btnClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(bottomItemClicked:)]) {
        [self.delegate bottomItemClicked:self.data];
    }
}
- (void)dataDidChange {
    BottomItemModel *model = self.data;
    _bottomLabel.text = model.titleName;
    UIImage *image = [UIImage imageNamed:model.imageName];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:image];
    _centerImageView.frame = CGRectMake(0.5 * (self.frame.size.width - tempImageView.frame.size.width), 0.5 * (self.frame.size.height - tempImageView.frame.size.height), tempImageView.frame.size.width, tempImageView.frame.size.height);
    _centerImageView.image = image;
}

@end
