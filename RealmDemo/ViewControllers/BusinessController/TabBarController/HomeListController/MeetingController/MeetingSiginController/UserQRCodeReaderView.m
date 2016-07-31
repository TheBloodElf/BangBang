/*
 * UserQRCodeReaderController
 *
 * Copyright 2014-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "UserQRCodeReaderView.h"
@interface UserQRCodeReaderView ()
{
    //扫描二维码框
    UIImageView *imageQRView;
    //中间一直移动的线条
    UIImageView *lineView;
    //当前线条移动的方向
    NAVIGATION_DIRECTION direction;
    
    //将二维码放入框内，即可自动扫描
    UILabel *label;
}
//@property (nonatomic, strong) CAShapeLayer *overlay;

@end

@implementation UserQRCodeReaderView

- (id)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
      direction = E_NAVIGATION_DIRECTION_DOWN;
      self.backgroundColor = [UIColor clearColor];
      
      [self configUI];
      [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(moveLine) userInfo:nil repeats:YES];
      
  }
  
  return self;
}

- (void)moveLine
{
    CGRect rect = lineView.frame;
    if(direction == E_NAVIGATION_DIRECTION_DOWN)
    {
        rect.origin.y += 1;
        if(rect.origin.y >= MAIN_SCREEN_WIDTH - 100)
            direction = E_NAVIGATION_DIRECTION_UP;
    }
    else
    {
        rect.origin.y -= 1;
        if(rect.origin.y <= 50)
            direction = E_NAVIGATION_DIRECTION_DOWN;
    }
    lineView.frame = rect;
}

- (void)configUI
{
    
    //创建扫描框
    CGFloat iamgeQtViewMAIN_SCREEN_HEIGHT = (MAIN_SCREEN_WIDTH - 40) * 250 / 280;
    imageQRView = [[UIImageView alloc] initWithFrame:CGRectMake(20, MAIN_SCREEN_HEIGHT * 70 / 504 , MAIN_SCREEN_WIDTH - 40, iamgeQtViewMAIN_SCREEN_HEIGHT)];
    imageQRView.image = [UIImage imageNamed:@"qcoreFrame"];
    imageQRView.backgroundColor = [UIColor clearColor];
    [self addSubview:imageQRView];
    
    //创建中间的线
    lineView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 50, MAIN_SCREEN_WIDTH - 40 - 20, 5)];
    lineView.image = [UIImage imageNamed:@"qcoreLine"];
    [imageQRView addSubview:lineView];
    
    
    //创建下面的文字视图
    label = [[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(imageQRView.frame) + 26 , MAIN_SCREEN_WIDTH, 12)];
    label.text = @"将二维码放入框内，即可自动扫描";
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    
}


@end

