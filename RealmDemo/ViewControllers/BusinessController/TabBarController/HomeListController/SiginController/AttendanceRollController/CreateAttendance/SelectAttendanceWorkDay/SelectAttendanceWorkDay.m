//
//  SelectAttendanceWorkDay.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/23.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SelectAttendanceWorkDay.h"

#define ButtonBeginTag 1001

@interface SelectAttendanceWorkDay ()

@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIView *centerView;

@end

@implementation SelectAttendanceWorkDay

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //被选中的按钮 day是12345678 按钮下标是01234567 所以要-1
    for (NSNumber *day in _userSelectDays) {
        UIButton *button = [self.centerView viewWithTag:day.intValue - 1 + ButtonBeginTag];
        button.selected = YES;
    }
}

- (void)setSelectedAtIndex:(NSInteger)index {
    UIButton *button = [self.centerView viewWithTag:index + ButtonBeginTag];
    button.selected = !button.selected;
}
- (NSArray<NSNumber*> *)getSelectedBtn {
    NSMutableArray <NSNumber *> *array = [@[] mutableCopy];
    for (NSInteger i = 0; i < 8; i ++) {
        UIButton *button = [self.centerView viewWithTag:i + ButtonBeginTag];
        if(button.selected == YES) {
            [array addObject:@(button.tag - ButtonBeginTag + 1)];
        }
    }
    return [array copy];
}
- (IBAction)btnClicked:(UIButton*)sender {
    [self setSelectedAtIndex:sender.tag - ButtonBeginTag];
}

- (IBAction)calcleBtnAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)okBtnAction:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectAttendanceWorkDay:)]) {
        [self.delegate selectAttendanceWorkDay:[self getSelectedBtn]];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
