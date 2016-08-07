//
//  MoreViewController.m
//  RealmDemo
//
//  Created by Mac on 16/8/6.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewHeight.constant = 2 * (MAIN_SCREEN_WIDTH / 3.f) + 21 * 2 + 10;
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view from its nib.
}
//一直刷新时间
- (void)updateTime {
    NSDate *currDate = [NSDate date];
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld月%02ld日 %@",currDate.month,currDate.day,currDate.weekdayStr];
    self.dateLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",currDate.hour,currDate.minute];
}
- (IBAction)btnClicked:(UIButton*)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(MoreViewDidClicked:)]) {
        [self.delegate MoreViewDidClicked:(int)sender.tag - 1000];
    }
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (IBAction)exitClicked:(id)sender {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}
@end
