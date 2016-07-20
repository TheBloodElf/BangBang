//
//  RepCalendarController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "RepCalendarDetailController.h"
#import "RepCalendarEditController.h"
#import "RepCalendarView.h"
#import "Calendar.h"

@interface RepCalendarDetailController () {
    RepCalendarView *_repCalendarView;
    Calendar *_calendar;
}

@end

@implementation RepCalendarDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    _repCalendarView = [[RepCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 50)];
    _repCalendarView.data = _calendar;
    [self.view addSubview:_repCalendarView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)rightClicked:(UIBarButtonItem*)item {
    RepCalendarEditController *edit = [RepCalendarEditController new];
    edit.data = _calendar;
    [self.navigationController pushViewController:edit animated:YES];
}
- (void)dataDidChange {
    _calendar = [Calendar copyFromCalendar:self.data];
}

@end
