//
//  MuliteSelectTopImageView.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/5.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "MuliteSelectTopImageView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MuliteSelectTopImageView () {
    UIButton *_topBtn;
    UIImageView *_bottomImageView;
}

@end

@implementation MuliteSelectTopImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _bottomImageView.layer.cornerRadius = frame.size.width / 2.f;
        _bottomImageView.clipsToBounds = YES;
        [self addSubview:_bottomImageView];
        
        _topBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _topBtn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [_topBtn addTarget:self action:@selector(topBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_topBtn];
    }
    return self;
}

- (void)topBtnClicked:(UIButton*)btn {
    if(self.delegate && [self.delegate respondsToSelector:@selector(muliteSelectTopDel:)]) {
        [self.delegate muliteSelectTopDel:self.data];
    }
}

- (void)dataDidChange {
    SelectEmployeeModel *model = self.data;
    [_bottomImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"soft_logo_icon"]];
}

@end
