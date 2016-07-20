//
//  ComCalendarController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/20.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "ComCalendarDetailController.h"
#import "ComCalendarEditController.h"
#import "ComCalendarView.h"
#import "Calendar.h"

@interface ComCalendarDetailController () {
    Calendar *_currCalendar;
    ComCalendarView *_comCalendarView;
}

@end

@implementation ComCalendarDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    _comCalendarView = [[ComCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - 50)];
    _comCalendarView.data = _currCalendar;
    [self.view addSubview:_comCalendarView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(rightClicked:)];
    // Do any additional setup after loading the view.
}
- (void)rightClicked:(UIBarButtonItem*)item {
    ComCalendarEditController *edit = [ComCalendarEditController new];
    edit.data = _currCalendar;
    [self.navigationController pushViewController:edit animated:YES];
}
- (void)dataDidChange {
    _currCalendar = [Calendar copyFromCalendar:self.data];
}
@end
