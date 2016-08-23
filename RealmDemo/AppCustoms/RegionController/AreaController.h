//
//  AreaController.h
//  fadein
//
//  Created by Apple on 15/12/22.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AreaController : UIViewController
/**
 *  该市所有区的数组
 */
@property (nonatomic, retain) NSArray *areaArr;

//省名
@property (nonatomic, copy) NSString *regionName;

//市名
@property (nonatomic, copy) NSString *cityName;

//@property (nonatomic, retain) id<AreaControllerDelegate> delegate;

@end
