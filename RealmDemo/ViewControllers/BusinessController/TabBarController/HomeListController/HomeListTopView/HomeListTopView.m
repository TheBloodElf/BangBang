//
//  HomeListTopView.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/13.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HomeListTopView.h"
#import "CalendarView.h"
#import "TaskView.h"

@interface HomeListTopView ()<UIScrollViewDelegate,CalendarViewDeleagate,TaskViewDelegate> {
    UIButton *_calendarBtn;//个人日程
    UIButton *_taskBtn;//团队任务
    UIScrollView *_scrollView;//日程和任务的滚动视图
    UIView *_lineView;//按钮下面的线
}

@end

@implementation HomeListTopView
#pragma mark -- 
#pragma mark -- init
- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        //创建按钮
        _calendarBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _calendarBtn.frame = CGRectMake(0, 0, frame.size.width / 2.f, 32);
        [_calendarBtn setTitle:@"个人日程" forState:UIControlStateNormal];
        [_calendarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _calendarBtn.backgroundColor = [UIColor homeListColor];
        _calendarBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_calendarBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_calendarBtn];
        
        _taskBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _taskBtn.frame = CGRectMake(frame.size.width / 2.f, 0, frame.size.width / 2.f, 32);
        [_taskBtn setTitle:@"团队任务" forState:UIControlStateNormal];
        [_taskBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _taskBtn.backgroundColor = [UIColor homeListColor];
        _taskBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_taskBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_taskBtn];
        //创建线
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, frame.size.width / 2, 2)];
        _lineView.backgroundColor = [UIColor colorWithRed:10/255.f green:185/255.f blue:153/255.f alpha:1];
        [self addSubview:_lineView];
        //创建滚动视图
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 32, frame.size.width, MAIN_SCREEN_WIDTH / 2.f)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;
        _scrollView.contentSize = CGSizeMake(frame.size.width * 2, _scrollView.frame.size.height);
        _scrollView.pagingEnabled = YES;
        CalendarView *calendarView = [[NSBundle mainBundle] loadNibNamed:@"CalendarView" owner:nil options:nil][0];
        calendarView.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        calendarView.delegate = self;
        [calendarView setupUI];
        [_scrollView addSubview:calendarView];
        TaskView *taskView = [[NSBundle mainBundle] loadNibNamed:@"TaskView" owner:nil options:nil][0];
        taskView.frame = CGRectMake(_scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
        taskView.delegate = self;
        [taskView setupUI];
        [_scrollView addSubview:taskView];
        [self addSubview:_scrollView];
    }
    return self;
}
#pragma mark -- 
#pragma mark -- CalendarViewDeleagate
//今天完成日程被点击
- (void)todayFinishCalendar {
    if(self.delegate && [self.delegate respondsToSelector:@selector(todayFinishCalendar)]) {
        [self.delegate todayFinishCalendar];
    }
}
//本周完成日程被点击
- (void)weekFinishCalendar {
    if(self.delegate && [self.delegate respondsToSelector:@selector(weekFinishCalendar)]) {
        [self.delegate weekFinishCalendar];
    }
}
#pragma mark -- 
#pragma mark -- TaskViewDelegate
//我委派的任务被点击
- (void)createTaskClicked {
    if(self.delegate && [self.delegate respondsToSelector:@selector(createTaskClicked)]) {
        [self.delegate createTaskClicked];
    }
}
//我负责的任务被点击
- (void)chargeTaskClicked {
    if(self.delegate && [self.delegate respondsToSelector:@selector(chargeTaskClicked)]) {
        [self.delegate chargeTaskClicked];
    }
}

#pragma mark --
#pragma mark -- BtnClicked
- (void)btnClicked:(UIButton*)btn {
    if(btn == _calendarBtn) {//日程被点击
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {//任务被点击
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
    }
}
#pragma mark -- 
#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //线条移动
    CGFloat scrollX = scrollView.contentOffset.x;
    _lineView.frame = CGRectMake(scrollX / 2, 30, scrollView.frame.size.width / 2, 2);
}
@end
