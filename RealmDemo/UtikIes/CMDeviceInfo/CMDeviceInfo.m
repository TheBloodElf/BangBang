//
//  CMDeviceInfo.m
//  fadein
//
//  Created by Maverick on 15/12/3.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import "CMDeviceInfo.h"
#import "sys/utsname.h"

NSString * const VENDOR_IDENTIFIER_KEY  = @"com.iNoknok.fadein.vendor";
NSString * const IDFV_KEY = @"com.iNoknok.fadein.idfv";
NSString * const IDFV_APP_SUFFIX = @"-fadein-ios";

@implementation CMDeviceInfo


#pragma mark -
#pragma mark - public methods

+ (NSString *)deviceType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *type = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([type isEqualToString:@"i386"] || [type isEqualToString:@"x86_64"]) {
        type = @"Simulator";
    }
    
    if (type == nil || type.length == 0) {
        type = [[UIDevice currentDevice].model copy];
    }
    
    return type;
}


+ (CGFloat)mainScreenWidth {
    return [UIScreen mainScreen].bounds.size.width;
    
}

+ (CGFloat)mainScreenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

//UUID（Universally Unique Identifier）:通用唯一识别码，每次生成均不一样，所以第一次生成后需要保存到钥匙串，这样即使应用删除再重装仍然可以从钥匙串得到它
+ (NSString *)uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

#pragma mark -
#pragma mark - pravite methods

+ (id)load:(NSString *)vendor {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [CMDeviceInfo getKeychainQuery:vendor];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setValue:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];}
        @catch (NSException *e) {NSLog(@"Unarchive of %@ failed: %@", vendor, e);}
        @finally {}
    }
    
    if (keyData) {
        CFRelease(keyData);
    }
    
    return [ret objectForKey:IDFV_KEY];
}

+ (void)save:(NSString *)vendor data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [CMDeviceInfo getKeychainQuery:vendor];
    //Delete old item before add new item
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)vendor {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys: (__bridge id)kSecClassGenericPassword,
            (__bridge id)kSecClass, vendor, (__bridge id)kSecAttrService, vendor, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible, nil];
}

+ (void)delete:(NSString *)vendor {
    NSMutableDictionary *keychainQuery = [CMDeviceInfo getKeychainQuery:vendor];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}



@end
