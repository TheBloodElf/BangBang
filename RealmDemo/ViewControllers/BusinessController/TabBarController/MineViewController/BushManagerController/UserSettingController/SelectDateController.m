//
//  SelectDateController.m
//  RealmDemo
//
//  Created by Mac on 16/7/16.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SelectDateController.h"

@interface SelectDateController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *dataPicker;

@end

@implementation SelectDateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataPicker.datePickerMode = self.datePickerMode;
    self.dataPicker.date = self.needShowDate ?: [NSDate date];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)sureClicked:(id)sender {
    if(self.selectDateBlock) {
        self.selectDateBlock(self.dataPicker.date);
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)quitClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
