//
//  RepCalendarDetailController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/21.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepCalendarDetailController.h"
#import "RepCalendarView.h"
#import "RepCalendarEditController.h"
#import "Calendar.h"
#import "UserHttp.h"
#import "UserManager.h"

@interface RepCalendarDetailController ()<RepCalendarEditDelegate> {
    RepCalendarView *_repCalendarView;
    Calendar *_calendar;
    UserManager *_userManager;
}

@end

@implementation RepCalendarDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日程详情";
    _userManager = [UserManager manager];
    if(_calendar.status == 1 )//今天如果是被删除或者被完成的也不添加工具栏 未完成就有下面的操作按钮
        _repCalendarView = [[RepCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 50 - 64)];
    else
        _repCalendarView = [[RepCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 64)];
    _repCalendarView.data = _calendar;
    [self.view addSubview:_repCalendarView];
    if(_calendar.status == 1) {//今天如果是被删除或者被完成的也不添加工具栏
        if([_calendar.created_by isEqualToString:_userManager.user.user_guid])//如果是自己创建的 就可以修改
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightClicked:)];
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
        okImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 4.f, 22);
        [okBtn addSubview:okImage];
        
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
        delImage.center = CGPointMake(MAIN_SCREEN_WIDTH / 4.f, 22);
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
- (void)dataDidChange {
    _calendar = [[Calendar alloc] initWithJSONDictionary:[self.data JSONDictionary]];
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
        [UserHttp updateUserCalendar:_calendar handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            [_userManager updateCalendar:_calendar];
            [self.navigationController.view showSuccessTips:@"完成成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
//        [_userManager updateCalendar:_calendar];
//        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"整个" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //status 状态0-已删除，1-正常，2-已完成
        _calendar.status = 2;
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp updateUserCalendar:_calendar handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            [_userManager updateCalendar:_calendar];
            [self.navigationController.view showSuccessTips:@"完成成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }];

//        [_userManager updateCalendar:_calendar];
//        [self.navigationController popViewControllerAnimated:YES];
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
        NSMutableArray *array = [[_calendar.deleted_dates componentsSeparatedByString:@","] mutableCopy];
        [array addObject:_calendar.rdate];
        _calendar.deleted_dates = [array componentsJoinedByString:@","];
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp updateUserCalendar:_calendar handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            [_userManager updateCalendar:_calendar];
            [self.navigationController.view showSuccessTips:@"删除成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
//        [_userManager updateCalendar:_calendar];
//        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *alertSure = [UIAlertAction actionWithTitle:@"整个" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //status 状态0-已删除，1-正常，2-已完成
        _calendar.status = 0;
        [self.navigationController.view showLoadingTips:@""];
        [UserHttp updateUserCalendar:_calendar handler:^(id data, MError *error) {
            [self.navigationController.view dismissTips];
            if(error) {
                [self.navigationController.view showFailureTips:error.statsMsg];
                return ;
            }
            [_userManager updateCalendar:_calendar];
            [self.navigationController.view showSuccessTips:@"删除成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
//        [_userManager updateCalendar:_calendar];
//        [self.navigationController popViewControllerAnimated:YES];
    }];
    [alertVC addAction:alertCancel];
    [alertVC addAction:currAlertSure];
    [alertVC addAction:alertSure];
    [self presentViewController:alertVC animated:YES completion:nil];
}
- (void)rightClicked:(UIBarButtonItem*)item {
    RepCalendarEditController *com = [RepCalendarEditController new];
    com.data = _calendar;
    com.delegate = self;
    [self.navigationController pushViewController:com animated:YES];
}
#pragma mark -- RepCalendarEditDelegate
- (void)RepCalendarEdit:(Calendar *)Calendar {
    _calendar = Calendar;
    _repCalendarView.data = Calendar;
}
@end
