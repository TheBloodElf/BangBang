//
//  AvaterBroseController.m
//  fadein
//
//  Created by Apple on 16/3/30.
//  Copyright © 2016年 Maverick. All rights reserved.
//

#import "AvaterBroseController.h"

@interface AvaterBroseController ()
{
    Photo *_photo;
    ShowBigImageScroller *big;
}
@end

@implementation AvaterBroseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(leftAction:)];
    big = [[ShowBigImageScroller alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, MAIN_SCREEN_HEIGHT)];
    big.backgroundColor = [UIColor blackColor];
    big.photo = _photo;
    [big setupUI];
    WeakSelf(weakSelf)
    __weak typeof(ShowBigImageScroller*) weakBig = big;
    big.clickedBlock = ^()
    {
        if(weakSelf.navigationController.navigationBar.hidden)
            [weakSelf.navigationController setNavigationBarHidden:NO animated:NO];
        else
            [weakSelf.navigationController setNavigationBarHidden:YES animated:NO];
        weakBig.backgroundColor = [weakBig.backgroundColor isEqual:[UIColor whiteColor]] ? [UIColor blackColor] :[UIColor whiteColor];
    };
    [self.view addSubview:big];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftAction:(UIBarButtonItem*)item
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    WeakSelf(weakSelf)
    big.clickedBlock = ^()
    {
        [weakSelf.navigationController popViewControllerAnimated:NO];
    };
    [big loadAnimation];
}
- (void)dataDidChange
{
    _photo = self.data;
}

@end
