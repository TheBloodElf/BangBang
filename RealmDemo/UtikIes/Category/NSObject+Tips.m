//
//  NSObject+Tips.m
//  Foomoo
//
//  Created by QFish on 6/6/14.
//  Copyright (c) 2014 QFish.inc. All rights reserved.
//

#import "NSObject+Tips.h"

__weak MBProgressHUD * _sharedHud;

@implementation UIView (Tips)

- (MBProgressHUD *)showTips:(NSString *)message autoHide:(BOOL)autoHide
{
    UIView * container = self;
    
    if ( container )
    {
        if ( nil != _sharedHud )
        {
            [_sharedHud hide:NO];
        }
        
        UIView * view = self;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = message;
		hud.detailsLabelFont = [UIFont systemFontOfSize:15];
        _sharedHud = hud;
        
        if ( autoHide )
        {
            [hud hide:YES afterDelay:2.f];
        }
    }
    
    return _sharedHud;
}

- (MBProgressHUD *)showTipsWithYOffset:(NSString *)message autoHide:(BOOL)autoHide
{
    UIView * container = self;
    
    if ( container )
    {
        if ( nil != _sharedHud )
        {
            [_sharedHud hide:NO];
        }
        
        UIView * view = self;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = message;
        hud.detailsLabelFont = [UIFont systemFontOfSize:15];
        hud.yOffset -= 50;
        _sharedHud = hud;
        
        if ( autoHide )
        {
            [hud hide:YES afterDelay:2.f];
        }
    }
    
    return _sharedHud;
}

- (MBProgressHUD *)showMessageTips:(NSString *)message
{
    return [self showTips:message autoHide:YES];
}

- (MBProgressHUD *)showSuccessTips:(NSString *)message
{
    return [self showUpImageSuccessTips:message];
}

- (MBProgressHUD *)showFailureTips:(NSString *)message
{
    UIView * container = self;
    
    if ( container )
    {
        if ( nil != _sharedHud )
        {
            [_sharedHud hide:NO];
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:container animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"create_close"]];
        hud.detailsLabelText = message;
        hud.detailsLabelFont = [UIFont systemFontOfSize:15];
        _sharedHud = hud;
        
        [hud hide:YES afterDelay:2.f];
    }
    
    return _sharedHud;
}

- (MBProgressHUD *)showFailureTipsWithYOffset:(NSString *)message
{
    return [self showTipsWithYOffset:message autoHide:YES];
}

- (MBProgressHUD *)showLoadingTips:(NSString *)message
{
    UIView * container = self;
    
    if ( container )
    {
        if ( nil != _sharedHud )
        {
            [_sharedHud hide:NO];
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:container animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.detailsLabelText = message;
        hud.detailsLabelFont = [UIFont systemFontOfSize:15];
        
        hud.square = YES;
        
        _sharedHud = hud;
    }

    return _sharedHud;
}

- (MBProgressHUD *)showUpImageSuccessTips:(NSString *)message
{
    UIView * container = self;
    
    if ( container )
    {
        if ( nil != _sharedHud )
        {
            [_sharedHud hide:NO];
        }
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:container animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"create_ok"]];
        hud.detailsLabelText = message;
        hud.detailsLabelFont = [UIFont systemFontOfSize:15];
        _sharedHud = hud;
 
        hud.yOffset = -MAIN_SCREEN_WIDTH*0.1;
        hud.square = YES;
        
        [hud hide:YES afterDelay:2.f];
    }
    
    return _sharedHud;
}


- (void)dismissTips
{
    [_sharedHud hide:YES];
    _sharedHud = nil;
}

@end

@implementation UIViewController (Tips)

- (MBProgressHUD *)showMessageTips:(NSString *)message
{
    return [self.view showTips:message autoHide:YES];
}

- (MBProgressHUD *)showSuccessTips:(NSString *)message
{
    return [self.view showUpImageSuccessTips:message];
}

- (MBProgressHUD *)showFailureTips:(NSString *)message
{
    return [self.view showFailureTips:message];
}

- (MBProgressHUD *)showFailureTipsWithYOffset:(NSString *)message
{
    return [self.view showTipsWithYOffset:message autoHide:YES];
}

- (MBProgressHUD *)showLoadingTips:(NSString *)message
{
    return [self.view showLoadingTips:message];
}

- (MBProgressHUD *)showUpImageSuccessTips:(NSString *)message
{
    return [self.view showUpImageSuccessTips:message];
}

- (void)dismissTips
{
    [self.view dismissTips];
}

@end