//
//  SelectAttendanceRange.m
//  BangBang
//
//  Created by lottak_mac2 on 16/6/22.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "SelectAttendanceRange.h"

#define ButtonBeginTag 1001

@interface SelectAttendanceRange ()
@property (weak, nonatomic) IBOutlet UIButton *calcleBtn;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@end

@implementation SelectAttendanceRange

- (void)viewDidLoad {
    [super viewDidLoad];
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
            range = 100 * (button.tag - ButtonBeginTag + 1);
            break;
        }
    }
    return range;
}
- (IBAction)btnClicked:(UIButton*)sender {
    [self setSelectedAtIndex:sender.tag - ButtonBeginTag];
}


- (IBAction)cancleBtnAction:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)okBntAction:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectAttendanceRange:)]) {
        [self.delegate selectAttendanceRange:[self getSelectedBtn]];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
