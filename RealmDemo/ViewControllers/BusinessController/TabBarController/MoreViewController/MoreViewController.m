//
//  MoreViewController.m
//  RealmDemo
//
//  Created by Mac on 16/8/6.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)exitClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(MoreViewDidClicked:)]) {
        [self.delegate MoreViewDidClicked:@""];
    }
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}
@end
