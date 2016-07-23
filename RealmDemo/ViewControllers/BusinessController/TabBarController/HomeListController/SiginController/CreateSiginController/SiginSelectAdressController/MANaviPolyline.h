//
//  MANaviPolyline.h
//  officialDemo2D
//
//  Created by xiaoming han on 15/5/25.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <MAMapKit/MAPolyline.h>
#import "MANaviAnnotation.h"

@interface MANaviPolyline : NSObject<MAOverlay>

@property (nonatomic, assign) MANaviAnnotationType type;
@property (nonatomic, strong) MAPolyline *polyline;

- (id)initWithPolyline:(MAPolyline *)polyline;

@end
