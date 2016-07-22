//
//  SelectAttendanceSpaceTime.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SelectAttendanceSpaceTime.h"
#define ButtonBeginTag 1001

@interface SelectAttendanceSpaceTime ()
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UILabel *titleName;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@end

@implementation SelectAttendanceSpaceTime

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleName.text = self.titleNameContent;
    //先初始化第一个被选中
    [self setSelectedAtIndex:0];
    // Do any additional setup after loading the view from its nib.
}
- (void)setSelectedAtIndex:(NSInteger)index {
    for (NSInteger i = 0; i < 6; i ++) {
        UIButton *button = [self.centerView viewWithTag:i + ButtonBeginTag];
        button.selected = NO;
    }
    UIButton *button = [self.centerView viewWithTag:index + ButtonBeginTag];
    button.selected = YES;
}
- (NSInteger)getSelectedBtn {
    NSInteger time = 0;
    for (NSInteger i = 0; i < 6; i ++) {
        UIButton *button = [self.centerView viewWithTag:i + ButtonBeginTag];
        if(button.selected == YES) {
            time = (button.tag - ButtonBeginTag) * 5;
            break;
        }
    }
    return time;
}
- (IBAction)btnClicked:(UIButton*)sender {
    [self setSelectedAtIndex:sender.tag - ButtonBeginTag];
}
- (IBAction)cancleBtnAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)okBtnAction:(id)sender {
    if(self.selectSpaceTimeBlock) {
        self.selectSpaceTimeBlock([self getSelectedBtn]);
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
