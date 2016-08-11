//
//  AttachPicCollection.m
//  RealmDemo
//
//  Created by lottak_mac2 on 16/8/9.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import "AttachPicCollection.h"
#import "Attachment.h"

@interface AttachPicCollection ()
@property (weak, nonatomic) IBOutlet UIImageView *attachPicImage;
@property (weak, nonatomic) IBOutlet UIImageView *selectedBtn;

@end

@implementation AttachPicCollection

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)dataDidChange {
    Attachment *attachment = self.data;
    self.attachPicImage.image = [UIImage imageWithData:attachment.fileData];
    self.selectedBtn.hidden = !attachment.isSelected;
}
@end
