//
//  HomeListBottomViewCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "HomeListBottomViewCell.h"
#import "LocalUserApp.h"

@interface HomeListBottomViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *appImage;
@property (weak, nonatomic) IBOutlet UILabel *appName;

@end

@implementation HomeListBottomViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    LocalUserApp *appModel = self.data;
    self.appName.text = appModel.titleName;
    self.appImage.image = [UIImage imageNamed:appModel.imageName];  
}

@end
