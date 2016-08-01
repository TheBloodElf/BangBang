//
//  MeetingRoomTimeCollectionCell.h
//  RealmDemo
//
//  Created by lottak_mac2 on 16/7/29.
//  Copyright © 2016年 com.luohaifang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingRoomCellModel.h"

@protocol MeetingRoomTimeDelegate <NSObject>

- (void)MeetingRoomTime:(MeetingRoomCellModel*)model;

@end

@interface MeetingRoomTimeCollectionCell : UICollectionViewCell

@property (nonatomic, weak) id<MeetingRoomTimeDelegate> delegate;

@end
