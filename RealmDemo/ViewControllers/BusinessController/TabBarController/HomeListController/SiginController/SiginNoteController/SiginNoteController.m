//
//  SiginNoteController.m
//  BangBang
//
//  Created by lottak_mac2 on 16/5/24.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SiginNoteController.h"
#import "SelectDateController.h"
#import "UserHttp.h"
#import "IdentityManager.h"
#import "UserManager.h"
//日历的高度
#define Calendar_Height 230

@interface SiginNoteController ()<JTCalendarDelegate,UIWebViewDelegate>
{
    UserManager *_userManager;
    UILabel *_rightBarLabel;//右边导航
    NSDate *_currDate;//当前用户选择的时间
    UIWebView *_webView;//下面显示签到记录的网页
    NSMutableArray<NSString*> *_siginedArr;//所有签到记录数组 以便统计有异常的天进行标记
}
@property (nonatomic, strong) JTCalendarManager *calendarManager;//日历管理器
@property (strong, nonatomic) JTHorizontalCalendarView *calendarContentView;//日历视图
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;

@end

@implementation SiginNoteController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"签到记录";
    self.view.backgroundColor = [UIColor whiteColor];
    _userManager = [UserManager manager];
    _currDate = [NSDate date];
    _siginedArr = [@[] mutableCopy];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([self.data isEqualToString:@"YES"]) return;
    self.data = @"YES";
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, Calendar_Height + 1 , MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT - Calendar_Height - 1 - 64)];
    [self.view addSubview:_webView];
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView webViewDelegate:self handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@punchcard/MySignIn?userGuid=%@&access_token=%@&companyNo=%ld",XYFMobileDomain,_userManager.user.user_guid,[IdentityManager manager].identity.accessToken,_userManager.user.currCompany.company_no]]];
    [_webView loadRequest:request];
    
    self.calendarManager = [JTCalendarManager new];
    self.calendarManager.delegate = self;
    [self.calendarManager setDate:_currDate];
    self.calendarContentView = [[JTHorizontalCalendarView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, Calendar_Height )];
    self.calendarManager.contentView = self.calendarContentView;
    [self.view addSubview:self.calendarContentView];
    _rightBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    _rightBarLabel.textColor = [UIColor whiteColor];
    _rightBarLabel.textAlignment = NSTextAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarLabel];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tgrAction:)];
    [_rightBarLabel addGestureRecognizer:tgr];
    _rightBarLabel.userInteractionEnabled = YES;
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@(_currDate.year),@(_currDate.month)]];
    NSRange contentRange = {0, [content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    _rightBarLabel.attributedText = content;
    [self getSiginWithDate:_currDate];
}
///选择时间
- (void)tgrAction:(id)action {
    SelectDateController * select = [SelectDateController new];
    select.datePickerMode = UIDatePickerModeDate;
    select.selectDateBlock = ^(NSDate *date) {
        NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@(date.year),@(date.month)]];
        NSRange contentRange = {0, [content length]};
        [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
        _rightBarLabel.attributedText = content;
        [self getSiginWithDate:date];
    };
    select.providesPresentationContextTransitionStyle = YES;
    select.definesPresentationContext = YES;
    select.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:select animated:NO completion:nil];
}
//根据当前时间获取当月的所有异常签到记录
- (void)getSiginWithDate:(NSDate*)date
{
    //获取当前月的第一天和最后一天
    [UserHttp getUsualSigin:_userManager.user.user_guid companyNo:_userManager.user.currCompany.company_no year:date.year month:date.month handler:^(id data, MError *error) {
        [_siginedArr removeAllObjects];
        [_siginedArr addObjectsFromArray:data];
        [self.calendarManager setDate:date];
        [self.calendarManager reload];
    }];
}
#pragma mark -- 
#pragma mark -- CalendarDelegate
- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView
{
    _currDate = dayView.date;
    NSString *timeDate = [NSString stringWithFormat:@"%@",@([_currDate timeIntervalSince1970])];
    //调用js的方法
    [_bridge callHandler:@"showSiginTimeUser" data:@{@"access_token":[IdentityManager manager].identity.accessToken,@"userGuid":_userManager.user.user_guid,@"companyNo":@(_userManager.user.currCompany.company_no),@"showDate":timeDate} responseCallback:^(id responseData) {
    }];
    [self.calendarManager reload];
}
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    dayView.circleView.hidden = YES;
    dayView.textLabel.textColor = [UIColor blackColor];
    if([dayView isFromAnotherMonth])
        dayView.textLabel.textColor = [UIColor grayColor];
    if(dayView.date.year == _currDate.year)
        if(dayView.date.month == _currDate.month)
            if(dayView.date.day == _currDate.day)
            {
                dayView.circleView.hidden = NO;
                dayView.circleView.backgroundColor = [UIColor siginColor];
                return;
            }
    NSDate *date = [NSDate date];
    if(dayView.date.year == date.year)
        if(dayView.date.month == date.month)
            if(dayView.date.day == date.day)
            {
                dayView.circleView.hidden = NO;
                dayView.circleView.backgroundColor = [UIColor grayColor];
            }   
    if([self isHavaError:dayView.date])
        dayView.dotView.hidden = NO;
    else
        dayView.dotView.hidden = YES;
}
//判断当前这天是不是有异常发生
- (BOOL)isHavaError:(NSDate*)date {
    for (NSString *timeStr in _siginedArr) {
        NSArray *tme = [timeStr componentsSeparatedByString:@"/"];
        if(date.day == [tme[2] integerValue])
            if(date.month == [tme[1] integerValue])
            return YES;
    }
    return NO;
}
/*!
 * Indicate the previous page became the current page.
 */
- (void)calendarDidLoadPreviousPage:(JTCalendarManager *)calendar;
{
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@([calendar date].year),@([calendar date].month)]];
    NSRange contentRange = {0, [content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    _rightBarLabel.attributedText = content;
    [self getSiginWithDate:calendar.date];
}
- (void)calendarDidLoadNextPage:(JTCalendarManager *)calendar
{
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@年%@月",@([calendar date].year),@([calendar date].month)]];
    NSRange contentRange = {0, [content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    _rightBarLabel.attributedText = content;
    [self getSiginWithDate:calendar.date];
}
@end
