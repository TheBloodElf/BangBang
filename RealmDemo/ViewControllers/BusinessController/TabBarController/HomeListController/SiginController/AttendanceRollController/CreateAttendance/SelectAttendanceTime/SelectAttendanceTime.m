//
//  SelectAttendanceTime.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/22.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SelectAttendanceTime.h"

@interface SelectAttendanceTime ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation SelectAttendanceTime

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)cancleBtnAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)okBtnAction:(id)sender {
    //通过代理回调
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectAttendanceTime:)]) {
        [self.delegate selectAttendanceTime:self.datePicker.date.timeIntervalSince1970];
    }
    //通过block回调
    if(self.selectTimeBlock) {
        self.selectTimeBlock(self.datePicker.date.timeIntervalSince1970);
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
