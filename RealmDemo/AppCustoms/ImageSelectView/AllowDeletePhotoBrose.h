//
//  AllowDeletePhotoBrose.h
//  fadein
//
//  Created by Apple on 15/12/19.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Photo;

@protocol AllowDeleteDelegate <NSObject>

@optional
- (void)allowDeleteSelect:(NSArray<Photo*>*)photoArr;

@end

@interface AllowDeletePhotoBrose : UIViewController

/**
 *  存放图片对象的数组
 */
@property (nonatomic, assign) BOOL hideDeleteBar;

/**
 *  存放图片对象的数组
 */
@property (nonatomic, retain) NSMutableArray<Photo*> *photoArr;

/**
 *  当前需要显示第几张
 */
@property (nonatomic, assign) int index;

@property (nonatomic, weak) id<AllowDeleteDelegate> delegate;

@end
