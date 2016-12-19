//
//  MoreSelectController.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/18.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MoreSelectController.h"
#import "XXXRoundMenuButton.h"

@interface MoreSelectController ()
@property (weak, nonatomic) IBOutlet XXXRoundMenuButton *menuButton;
@end

@implementation MoreSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.menuButton loadButtonWithIcons:@[
                                           [UIImage imageNamed:@"add_1"],
                                           [UIImage imageNamed:@"add_2"],
                                           [UIImage imageNamed:@"add_3"],
                                           [UIImage imageNamed:@"add_4"],
                                           [UIImage imageNamed:@"add_5"],
                                           [UIImage imageNamed:@"add_6"],
                                           [UIImage imageNamed:@"add_7"]
                                           ] startDegree:M_PI/2 layoutDegree:M_PI];
    [self.menuButton setButtonClickBlock:^(NSInteger idx) { 
        if(self.delegate && [self.delegate respondsToSelector:@selector(MoreViewDidClicked:)]) {
            [self.delegate MoreViewDidClicked:(int)idx];
        }
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
    self.menuButton.tintColor = [UIColor whiteColor];
    self.menuButton.mainColor = [UIColor clearColor];
    self.menuButton.jumpOutButtonOnebyOne = YES;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)exitClicked:(id)sender {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

@end
