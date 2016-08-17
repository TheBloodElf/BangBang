//
//  RegionController.h
//  fadein
//
//  Created by Apple on 15/12/13.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  地区页面
 */

@protocol RegionSelectAdressDelegate <NSObject>

- (void)regionSelectAdress:(NSString*)region city:(NSString*)city area:(NSString*)area;

@end

@interface RegionController : UIViewController

@property (nonatomic, weak) id<RegionSelectAdressDelegate> delegate;

@end
