//
//  DelayDateSelectController.m
//  RealmDemo
//
//  Created by Mac on 2016/11/15.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "DelayDateSelectController.h"
#import "SelectDelayDateView.h"
#import "CustomDelayDateView.h"

@interface DelayDateSelectController ()<SelectDelayDateDelegate,CustomDelayDelegate> {
    SelectDelayDateView *_selectDelayDateView;
    CustomDelayDateView *_customDelayDateView;
}
//下方的滚动视图
@property (weak, nonatomic) IBOutlet UIScrollView *bottomScrollView;

@end

@implementation DelayDateSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _bottomScrollView.contentSize = CGSizeMake(MAIN_SCREEN_WIDTH * 2, _bottomScrollView.frame.size.height);
    //#BANG-583 尽量用MAIN_SCREEN_WIDTH
    _selectDelayDateView = [[SelectDelayDateView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, _bottomScrollView.frame.size.height)];
    _selectDelayDateView.delegate = self;
    [_bottomScrollView addSubview:_selectDelayDateView];
    _customDelayDateView = [[CustomDelayDateView alloc] initWithFrame:CGRectMake(MAIN_SCREEN_WIDTH, 0, MAIN_SCREEN_WIDTH, _bottomScrollView.frame.size.height)];
    _customDelayDateView.delegate = self;
    [_bottomScrollView addSubview:_customDelayDateView];
}
//点击了背景，退出选择
- (IBAction)cancleClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
#pragma mark --
#pragma mark -- SelectDelayDateDelegate
//推迟多少秒
- (void)selectDelayDate:(int)second {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectDelayDate:)]) {
        [self.delegate selectDelayDate:second];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}
//自定义时间
- (void)selectCustom {
    [_bottomScrollView setContentOffset:CGPointMake(_bottomScrollView.frame.size.width, 0) animated:YES];
}
#pragma mark --
#pragma mark -- CustomDelayDelegate
- (void)customSelectDate:(NSDate*)date {
    if(self.delegate && [self.delegate respondsToSelector:@selector(customSelectDate:)]) {
        [self.delegate customSelectDate:date];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)customCancle {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
