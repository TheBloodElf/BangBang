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
    //先初始化第一个被选中
    [self setSelectedAtIndex:0];
    // Do any additional setup after loading the view from its nib.
}
- (void)setSelectedAtIndex:(NSInteger)index {
    for (NSInteger i = 0; i < 8; i ++) {
        UIButton *button = [self.centerView viewWithTag:i + ButtonBeginTag];
        button.selected = NO;
    }
    UIButton *button = [self.centerView viewWithTag:index + ButtonBeginTag];
    button.selected = YES;
}
- (NSInteger)getSelectedBtn {
    NSInteger range = 0;
    for (NSInteger i = 0; i < 8; i ++) {
        UIButton *button = [self.centerView viewWithTag:i + ButtonBeginTag];
        if(button.selected == YES) {
            range = (button.tag - ButtonBeginTag + 1);
            break;
        }
    }
    NSInteger time = 0;
    switch (range) {
        case 1:
            time = 1;
            break;
        case 2:
            time = 5;
            break;
        case 3:
            time = 10;
            break;
        case 4:
            time = 15;
            break;
        case 5:
            time = 30;
            break;
        case 6:
            time = 60;
            break;
        case 7:
            time = 90;
            break;
        default:
            time = 120;
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
