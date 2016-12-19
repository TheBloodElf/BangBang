//
//  CalendarSelectAlertTime.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/19.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "CalendarSelectAlertTime.h"
#define ButtonBeginTag 1001
@interface CalendarSelectAlertTime ()

@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *okBtn;
@property (weak, nonatomic) IBOutlet UIView *calcleBtn;
@end

@implementation CalendarSelectAlertTime

- (void)viewDidLoad {
    [super viewDidLoad];
    //如果有被选中的时间，则让响应的按钮处于选中状态
    if(_userSelectTime == 0) return;
    //获取应该被选中按钮的下标
    int index = 0;
    switch (_userSelectTime) {
        case 1: index = 0; break;
        case 5: index = 1; break;
        case 10: index = 2; break;
        case 15: index = 3; break;
        case 30: index = 4; break;
        case 60: index = 5; break;
        case 90: index = 6; break;
        case 120: index = 7; break;
        default: break;
    }
    UIButton *currButton = [self.centerView viewWithTag:index + ButtonBeginTag];
    currButton.selected = YES;
    // Do any additional setup after loading the view from its nib.
}
- (void)setSelectedAtIndex:(NSInteger)index {
    //当前被选中然后再次被点击，就去掉当前按钮点击状态就可以了
    UIButton *currButton = [self.centerView viewWithTag:index + ButtonBeginTag];
    if(currButton.selected == YES) {
        currButton.selected = NO;
        return;
    }
    //让当前按钮被点击
    for (NSInteger i = 0; i < 8; i ++) {
        UIButton *button = [self.centerView viewWithTag:i + ButtonBeginTag];
        button.selected = NO;
    }
    UIButton *button = [self.centerView viewWithTag:index + ButtonBeginTag];
    button.selected = YES;
}
- (NSInteger)getSelectedBtn {
    //或者按钮被选中的下标 index为-1表示没有被选中的按钮
    NSInteger index = -1;
    for (NSInteger i = 0; i < 8; i ++) {
        UIButton *button = [self.centerView viewWithTag:i + ButtonBeginTag];
        if(button.selected == YES) {
            index = i;
            break;
        }
    }
    NSInteger time = 0;
    switch (index) {
        case 0:
            time = 1;
            break;
        case 1:
            time = 5;
            break;
        case 2:
            time = 10;
            break;
        case 3:
            time = 15;
            break;
        case 4:
            time = 30;
            break;
        case 5:
            time = 60;
            break;
        case 6:
            time = 90;
            break;
        case 7:
            time = 120;
            break;
        default:
            time = 0;
            break;
    }
    return time;
}
- (IBAction)btnClicked:(UIButton*)sender {
    [self setSelectedAtIndex:sender.tag - ButtonBeginTag];
}

- (IBAction)cancleBtnAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)okBntAction:(id)sender {
    if(self.calendarSelectTime)
        self.calendarSelectTime((int)[self getSelectedBtn]);
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
