//
//  SigInListCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/21.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SigInListCell.h"
#import "SignIn.h"
#import "Photo.h"

@interface SigInListCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;//时间
@property (weak, nonatomic) IBOutlet UIImageView *avaterImage;//头像
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//员工名字
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;//分类
@property (weak, nonatomic) IBOutlet UIButton *adressLabel;//地址
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;//说明
@property (weak, nonatomic) IBOutlet UIButton *attemthLabel;//附件图片展示
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attemthHeight;

@end

@implementation SigInListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)dataDidChange {
    SignIn *signIn = [self.data deepCopy];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:signIn.create_on_utc / 1000];
    self.timeLabel.text = [NSString stringWithFormat:@"%ld/%02ld/%02ld %02ld:%02ld",date.year,date.month,date.day,date.hour,date.minute];
    [self.avaterImage sd_setImageWithURL:[NSURL URLWithString:signIn.create_avatar] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
    self.categoryLabel.text = [signIn categoryStr];
    self.nameLabel.text = signIn.create_name;
    [self.adressLabel setTitle:signIn.address forState:UIControlStateNormal];
    if([NSString isBlank:signIn.descriptionStr])
        self.detailLabel.text = @"说明：无";
    else
        self.detailLabel.text = [NSString stringWithFormat:@"说明：%@",signIn.descriptionStr];
    //得到图片的宽度
    CGFloat width = (MAIN_SCREEN_WIDTH - 66 - 10) / 3.f;
    if(width > 90)
        width = 90;
    if([NSString isBlank:signIn.attachments]) {
        self.attemthHeight.constant = 0.01f;
        return;
    }
    self.attemthHeight.constant = 90.f;
    NSArray *imageArr = [signIn.attachments componentsSeparatedByString:@","];
    for (int index = 0; index < imageArr.count; index ++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(index * (width + 5), 0, width, width)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageArr[index]] placeholderImage:[UIImage imageNamed:@"default_image_icon"]];
        [self.attemthLabel addSubview:imageView];
    }
    
}
//附件被点击
- (IBAction)attathmClicked:(id)sender {
    NSMutableArray *array = [@[] mutableCopy];
    for (int index = 0; index < self.attemthLabel.subviews.count; index ++) {
        UIImageView *imageView = self.attemthLabel.subviews[index];
        Photo *photo = [Photo new];
        photo.oiginalImage = imageView.image;
        UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
        CGRect rect=[imageView convertRect: imageView.bounds toView:window];
        photo.toRect = rect;
        photo.index = index;
        if(index == 0) {
            photo.fromRect = rect;
        }
        [array addObject:photo];
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(SigInListCellPhotoClicked:)]) {
        [self.delegate SigInListCellPhotoClicked:array];
    }
}
//地址被点击
- (IBAction)adressClicked:(id)sender {
    SignIn *signIn = self.data;
    CLLocationCoordinate2D c2D = CLLocationCoordinate2DMake(signIn.latitude, signIn.longitude);
    if(self.delegate && [self.delegate respondsToSelector:@selector(SigInListCellAdressClicked:)]) {
        [self.delegate SigInListCellAdressClicked:c2D];
    }
}

@end
