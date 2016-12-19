//
//  RepCalendarDetailController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/21.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepCalendarDetailController.h"
#import "CalendarRepDetailView.h"
#import "RepCalendarEditController.h"
#import "Calendar.h"
#import "UserHttp.h"
#import "UserManager.h"
#import "DelayDateSelectController.h"

@interface RepCalendarDetailController ()<RepCalendarEditDelegate,DelayDateSelectDelegate> {
    CalendarRepDetailView *_repCalendarView;
    Calendar *_calendar;
    UserManager *_userManager;
}

@end

@implementation RepCalendarDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日程详情";
    _userManager = [UserManager manager];
    _repCalendarView = [[CalendarRepDetailView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 50 - 64)];
    _repCalendarView.data = _calendar;
    [self.view addSubview:_repCalendarView];
    if(_calendar.status == 1) {//如果未完成
        //现在改成所有的日程都可以编辑
//        if([_calendar.created_by isEqualToString:_userManager.user.user_guid])//如果是自己创建的 就可以修改
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightClicked:)];
        //完成日程
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        okBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH / 2, MAIN_SCREEN_HEIGHT - 50 - 64, MAIN_SCREEN_WIDTH / 2, 50);
        okBtn.titleEdgeInsets = UIEdgeInsetsMake(35, 0, 0, 0);
        okBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [okBtn setTitle:@"完成日程" forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor colorFromHexCode:@"#848484"] forState:UIControlStateNormal];
        okBtn.backgroundColor = [UIColor colorFromHexCode:@"#eeeeee"];
        [okBtn addTarget:self action:@selector(finishCalendarClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:okBtn];
        UIImageView *okImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ic_complete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        okImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 4, 22);
        [okBtn addSubview:okImage];
        //删除日程
        UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        delBtn.frame = CGRectMake(0, MAIN_SCREEN_HEIGHT - 50 - 64, MAIN_SCREEN_WIDTH / 2, 50);
        delBtn.titleEdgeInsets = UIEdgeInsetsMake(35, 0, 0, 0);
        delBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [delBtn setTitle:@"删除日程" forState:UIControlStateNormal];
        [delBtn setTitleColor:[UIColor colorFromHexCode:@"#848484"] forState:UIControlStateNormal];
        delBtn.backgroundColor = [UIColor colorFromHexCode:@"#eeeeee"];
        [delBtn addTarget:self action:@selector(deleteCalendarClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:delBtn];
        UIImageView *delImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ic_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        delImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 4, 22);
        [delBtn addSubview:delImage];
        //推迟日程
//        UIButton *deyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        deyBtn.frame = CGRectMake(MAIN_SCREEN_WIDTH / 3 * 2, MAIN_SCREEN_HEIGHT - 50 - 64, MAIN_SCREEN_WIDTH / 3, 50);
//        deyBtn.titleEdgeInsets = UIEdgeInsetsMake(35, 0, 0, 0);
//        deyBtn.titleLabel.font = [UIFont systemFontOfSize:12];
//        [deyBtn setTitle:@"推迟日程" forState:UIControlStateNormal];
//        [deyBtn setTitleColor:[UIColor colorFromHexCode:@"#848484"] forState:UIControlStateNormal];
//        deyBtn.backgroundColor = [UIColor colorFromHexCode:@"#eeeeee"];
//        [deyBtn addTarget:self action:@selector(delayCalendarClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:delBtn];
//        UIImageView *deyImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"ic_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//        deyImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 6, 22);
//        [deyBtn addSubview:deyImage];
//        [self.view addSubview:deyBtn];
    } else {//如果完成就可以修改
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
    //如果是从业务的根视图进来的 就隐藏导航
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if([self.navigationController.viewControllers[0] isMemberOfClass:[NSClassFromString(@"REFrostedViewController") class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}
- (void)rightClicked:(UIBarButtonItem*)item {
    RepCalendarEditController *com = [RepCalendarEditController new];
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
    UIAlertAction *currAlertSure = [UIAlertAction actionWithTitle:@"本次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //status 状态0-已删除，1-正常，2-已完成
        NSMutableArray *array = [[_calendar.finished_dates componentsSeparatedByString:@","] mutableCopy];
        [array addObject:_calendar.rdate];
        _calendar.finished_dates = [array componentsJoinedByString:@","];
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp addCalendarFinishDate:_calendar.id finishDate:_calendar.rdate.doubleValue handler:^(id data, MError *error) {
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
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"整个" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    [alertVC addAction:currAlertSure];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];
}
//删除日程
- (void)deleteCalendarClicked:(UIButton*)btn {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"你确定要删除该日程?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *currAlertSure = [UIAlertAction actionWithTitle:@"本次" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //status 状态0-已删除，1-正常，2-已完成
        //#BANG-427 循环日程，进入某天已完成日程详情，再删除日程，则循环日程状态变成已经完成
        //以数据库中本日程状态为准
        if(_calendar.status == 2) {
            for (Calendar *calendar in [_userManager getCalendarArr]) {
                if(calendar.id == _calendar.id) {
                    _calendar.status = calendar.status;
                    break;
                }
            }
        }
        NSMutableArray *array = [[_calendar.deleted_dates componentsSeparatedByString:@","] mutableCopy];
        [array addObject:_calendar.rdate];
        _calendar.deleted_dates = [array componentsJoinedByString:@","];
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp addCalendarDeleteDate:_calendar.id deleteDate:_calendar.rdate.doubleValue handler:^(id data, MError *error) {
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
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"整个" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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
    [alertVC addAction:currAlertSure];
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
    _calendar.r_begin_date_utc += second * 1000;
    _calendar.r_end_date_utc += second * 1000;
    [_userManager updateCalendar:_calendar];
    _repCalendarView.data = _calendar;
}
- (void)customSelectDate:(NSDate*)date {
    
}
#pragma mark -- RepCalendarEditDelegate
- (void)RepCalendarEdit:(Calendar *)Calendar {
    _calendar = Calendar;
    _repCalendarView.data = Calendar;
}
@end
