//
//  MuliteSelectTopView.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/4.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "MuliteSelectTopView.h"
#import "MuliteSelectTopImageView.h"

#define LeftView_Max_Width 200

@interface MuliteSelectTopView  ()<UITextFieldDelegate,MuliteSelectTopImageViewDelegate> {
    UIScrollView *_leftScrollView;//左边显示头像的滚动视图
    UITextField *_rightTextField;//右边输入框
    NSArray<SelectEmployeeModel*> *_employeeArr;//员工数组
    CGFloat _itemWidth;//每个头像的宽高
}

@end

@implementation MuliteSelectTopView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _employeeArr = [@[] mutableCopy];
        _itemWidth = frame.size.height - 2 * 5;
        _leftScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 5, 0, _itemWidth)];
        _leftScrollView.showsVerticalScrollIndicator = NO;
        _leftScrollView.showsHorizontalScrollIndicator = NO;
        _leftScrollView.bounces = NO;
        _rightTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_leftScrollView.frame), 5, frame.size.width - 15 - CGRectGetMaxX(_leftScrollView.frame), _itemWidth)];
        _rightTextField.placeholder = @"搜索";
        _rightTextField.returnKeyType = UIReturnKeySearch;
        _rightTextField.borderStyle = UITextBorderStyleNone;
        _rightTextField.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:_leftScrollView];
        [self addSubview:_rightTextField];
    }
    return self;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(muliteSelectTextField:)]) {
        [self.delegate muliteSelectTextField:textField]
         ;
    }
    return YES;
}
#pragma mark -- 
#pragma mark -- MuliteSelectTopImageViewDelegate
- (void)muliteSelectTopDel:(SelectEmployeeModel*)model {
    if(self.delegate && [self.delegate respondsToSelector:@selector(muliteSelectDel:)]) {
        [self.delegate muliteSelectDel:model];
    }
}
- (void)dataDidChange {
    _employeeArr = self.data;
    //算出左边的滚动视图内容多宽
    CGFloat needWidth = _employeeArr.count * (_itemWidth + 7);
    //调整滚动视图和文本输入框的位置
    if(needWidth < LeftView_Max_Width) {
        _leftScrollView.frame = CGRectMake(15, 5, needWidth, _itemWidth);
    } else {
        _leftScrollView.frame = CGRectMake(15, 5, LeftView_Max_Width, _itemWidth);
    }
    _rightTextField.frame = CGRectMake(CGRectGetMaxX(_leftScrollView.frame), 5, self.frame.size.width - 15 - CGRectGetMaxX(_leftScrollView.frame), _itemWidth);
    _leftScrollView.contentSize = CGSizeMake(needWidth, _itemWidth);
    //先清空里面的头像
    for (UIView *view in _leftScrollView.subviews) {
        [view removeFromSuperview];
    }
    //填充头像
    for (int index = 0;index < _employeeArr.count;index ++) {
        CGFloat leftX = index * (_itemWidth + 7);
        MuliteSelectTopImageView *imageView = [[MuliteSelectTopImageView alloc] initWithFrame:CGRectMake(leftX, 0, _itemWidth, _itemWidth)];
        imageView.delegate = self;
        imageView.data = _employeeArr[index];
        [_leftScrollView addSubview:imageView];
    }
}
@end
