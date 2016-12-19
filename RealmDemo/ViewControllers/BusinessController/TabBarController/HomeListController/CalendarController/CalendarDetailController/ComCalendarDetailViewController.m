//
//  ComCalendarDetailViewController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/21.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarDetailViewController.h"
#import "ComCalendarEditController.h"
#import "CalendarComDetailView.h"
#import "Calendar.h"
#import "UserManager.h"
#import "DelayDateSelectController.h"
#import "UserHttp.h"

@interface ComCalendarDetailViewController ()<DelayDateSelectDelegate,ComCalendarEditDelegate> {
    Calendar *_calendar;
    CalendarComDetailView *_comCalendarView;
    UserManager *_userManager;
}

@end

@implementation ComCalendarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日程详情";
    _userManager = [UserManager manager];
    _comCalendarView = [[CalendarComDetailView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 50 - 64)];
    _comCalendarView.data = _calendar;
    [self.view addSubview:_comCalendarView];
    if(_calendar.status == 1) {//如果是自己创建的
        //现在改成所有的日程都可以编辑
//        if([_calendar.created_by isEqualToString:_userManager.user.user_guid])//如果是自己创建的 就可以修改
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightClicked:)];
        //完成日程
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        okBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH / 3, MAIN_SCREEN_HEIGHT - 50 - 64, MAIN_SCREEN_WIDTH / 3, 50);
        okBtn.titleEdgeInsets = UIEdgeInsetsMake(35, 0, 0, 0);
        okBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [okBtn setTitle:@"完成日程" forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor colorFromHexCode:@"#848484"] forState:UIControlStateNormal];
        okBtn.backgroundColor = [UIColor colorFromHexCode:@"#eeeeee"];
        [okBtn addTarget:self action:@selector(finishCalendarClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:okBtn];
        UIImageView *okImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ic_complete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        okImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 6, 22);
        [okBtn addSubview:okImage];
        //删除日程
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        delBtn.frame = CGRectMake(0, MAIN_SCREEN_HEIGHT - 50 - 64, MAIN_SCREEN_WIDTH / 3, 50);
        delBtn.titleEdgeInsets = UIEdgeInsetsMake(35, 0, 0, 0);
        delBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [delBtn setTitle:@"删除日程" forState:UIControlStateNormal];
        [delBtn setTitleColor:[UIColor colorFromHexCode:@"#848484"] forState:UIControlStateNormal];
        delBtn.backgroundColor = [UIColor colorFromHexCode:@"#eeeeee"];
        [delBtn addTarget:self action:@selector(deleteCalendarClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:delBtn];
        UIImageView *delImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ic_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        delImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 6, 22);
        [delBtn addSubview:delImage];
        //推迟日程
        UIButton *deyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        deyBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH / 3 * 2, MAIN_SCREEN_HEIGHT - 50 - 64, MAIN_SCREEN_WIDTH / 3, 50);
        deyBtn.titleEdgeInsets = UIEdgeInsetsMake(35, 0, 0, 0);
        deyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [deyBtn setTitle:@"推迟日程" forState:UIControlStateNormal];
        [deyBtn setTitleColor:[UIColor colorFromHexCode:@"#848484"] forState:UIControlStateNormal];
        deyBtn.backgroundColor = [UIColor colorFromHexCode:@"#eeeeee"];
        [deyBtn addTarget:self action:@selector(delayCalendarClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:delBtn];
        UIImageView *deyImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ic_task_delay"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        deyImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 6, 22);
        [deyBtn addSubview:deyImage];
        [self.view addSubview:deyBtn];
    } else {//如果完成就可以删除
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        delBtn.frame = CGRectMake(0, MAIN_SCREEN_HEIGHT - 50 - 64, MAIN_SCREEN_WIDTH , 50);
        delBtn.titleEdgeInsets = UIEdgeInsetsMake(35, 0, 0, 0);
        delBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [delBtn setTitle:@"删除日程" forState:UIControlStateNormal];
        [delBtn setTitleColor:[UIColor colorFromHexCode:@"#848484"] forState:UIControlStateNormal];
        delBtn.backgroundColor = [UIColor colorFromHexCode:@"#eeeeee"];
        [delBtn addTarget:self action:@selector(deleteCalendarClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:delBtn];
        UIImageView *delImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ic_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        delImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 2.f, 22);
        [delBtn addSubview:delImage];
    }
    // Do any additional setup after loading the view.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
- (void)rightClicked:(UIBarButtonItem*)item {
    ComCalendarEditController *com = [ComCalendarEditController new];
    com.data = _calendar;
    com.delegate = self;
    [self.navigationController pushViewController:com animated:YES];
}
- (void)dataDidChange {
    _calendar = self.data;
}
//完成日程
- (void)finishCalendarClicked:(UIButton*)btn {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定要完成该日程?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //status 状态0-已删除，1-正常，2-已完成
        _calendar.status = 2;
        _calendar.finishedon_utc = [NSDate date].timeIntervalSince1970 * 1000;
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp finishUserCalendar:_calendar handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                if(error.statsCode == -1009) {
                    _calendar.needSync = YES;
                    [_userManager updateCalendar:_calendar];
                    [self.navigationController popViewControllerAnimated:YES];
                    return ;
                }
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            [_userManager updateCalendar:_calendar];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    [alertVC addAction:alertCancel];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//删除日程
- (void)deleteCalendarClicked:(UIButton*)btn {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定要删除该日程?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //status 状态0-已删除，1-正常，2-已完成
        _calendar.status = 0;
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp deleteUserCalendar:_calendar.id handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                if(error.statsCode == -1009) {
                    _calendar.needSync = YES;
                    [_userManager updateCalendar:_calendar];
                    [self.navigationController popViewControllerAnimated:YES];
                    return ;
                }
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            [_userManager updateCalendar:_calendar];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
    [alertVC addAction:alertCancel];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];

}
//推迟日程
- (void)delayCalendarClicked:(UIButton*)btn {
    DelayDateSelectController *select = [DelayDateSelectController new];
    select.delegate = self;
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
#pragma mark -- DelayDateSelectDelegate
- (void)selectDelayDate:(int)second {
    //把开始时间和结束时间同时往后推迟second秒
    _calendar.begindate_utc += second * 1000;
    _calendar.enddate_utc += second * 1000;
    //这里要向服务器请求更新当前日程
    [self.navigationController.view showLoadingTips:@""];
    [UserHttp updateUserCalendar:_calendar handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        _comCalendarView.data = _calendar;
        if(error) {
            if(error.statsCode == -1009) {
                _calendar.needSync = YES;
                [_userManager updateCalendar:_calendar];
                [self.navigationController popViewControllerAnimated:YES];
                return ;
            }
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        [_userManager updateCalendar:_calendar];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
- (void)customSelectDate:(NSDate*)date {
    
}

#pragma amrk -- ComCalendarEditDelegate
- (void)ComCalendarEdit:(Calendar *)Calendar {
    _calendar = Calendar;
    _comCalendarView.data = Calendar;
}
@end
