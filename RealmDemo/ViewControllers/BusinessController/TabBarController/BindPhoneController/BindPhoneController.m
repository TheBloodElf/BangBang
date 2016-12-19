//
//  BindPhoneController.m
//  RealmDemo
//
//  Created by Mac on 2016/11/11.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "BindPhoneController.h"

@interface BindPhoneController ()

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation BindPhoneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _topLabel.adjustsFontSizeToFitWidth = YES;
    _bottomLabel.adjustsFontSizeToFitWidth = YES;
}
- (IBAction)bindCancle:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(bindCancle)]) {
        [self.delegate bindCancle];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)bindClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(bindPhoneClicked)]) {
        [self.delegate bindPhoneClicked];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
