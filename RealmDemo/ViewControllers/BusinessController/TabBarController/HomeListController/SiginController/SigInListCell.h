//
//  SigInListCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/21.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SigInListCellDelegate <NSObject>
//图片被点击
- (void)SigInListCellPhotoClicked:(NSArray*)photos;
//地址被点击
- (void)SigInListCellAdressClicked:(CLLocationCoordinate2D)cLLocationCoordinate2D;

@end

@interface SigInListCell : UITableViewCell

@property (nonatomic, weak) id<SigInListCellDelegate> delegate;

@end
