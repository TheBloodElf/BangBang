//
//  FaceInviteColleague.m
//  BangBang
//
//  Created by lottak_mac2 on 16/7/6.
//  Copyright © 2016年 Lottak. All rights reserved.
//

#import "FaceInviteColleague.h"
#import "UserHttp.h"
#import "UserManager.h"

@interface FaceInviteColleague ()

@property (weak, nonatomic) IBOutlet UIImageView *qrCodeImage;
@property (weak, nonatomic) IBOutlet UIButton *companyName;

@end

@implementation FaceInviteColleague

- (void)viewDidLoad {
    [super viewDidLoad];
    [UserHttp getReferrerURL:[UserManager manager].user.user_no handler:^(id data, MError *error) {
        [self.navigationController.view dismissTips];
        if(error) {
            [self.navigationController.view showFailureTips:error.statsMsg];
            return ;
        }
        NSString * shortUrl = data[@"url_short"];
        self.qrCodeImage.image = [QRCodeGenerator qrImageForString:shortUrl imageSize:200];
    }];
    [self.companyName setTitle:[UserManager manager].user.currCompany.company_name forState:UIControlStateNormal];
}
- (IBAction)exitVC:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
