//
//  SiginImageCell.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/22.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "SiginImageCell.h"

@interface SiginImageCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SiginImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    self.imageView.image = self.data;
}
- (IBAction)deleteClicked:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(SiginImageDelete:)]) {
        [self.delegate SiginImageDelete:self.data];
    }
}
@end
