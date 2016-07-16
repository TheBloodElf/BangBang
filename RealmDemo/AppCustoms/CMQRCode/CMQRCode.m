//
//  CMQRCode.m
//  fadein
//
//  Created by Maverick on 15/12/10.
//  Copyright © 2015年 Maverick. All rights reserved.
//

#import "CMQRCode.h"
#import "ZXingObjC.h"

@implementation CMQRCode


#pragma mark -
#pragma mark - Public Methods

+ (UIImage *)QRCodeImage:(NSString *)QRCodeStr {
    NSData *QRCodedata = [QRCodeStr dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *CI_QRFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [CI_QRFilter setValue:QRCodedata forKey:@"inputMessage"];
    [CI_QRFilter setValue:@"H" forKey:@"inputCorrectionLevel"]; //修正等級 L: 7% M: 15% Q: 25% H: 30%
    CIImage *CI_QRImage = CI_QRFilter.outputImage;
    
    CGRect extent = CGRectIntegral(CI_QRImage.extent);
    CGFloat len = MIN([[UIScreen mainScreen] currentMode].size.width, [[UIScreen mainScreen] currentMode].size.height);
    CGFloat scale = MIN(len/CGRectGetWidth(extent), len/CGRectGetHeight(extent));
    
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
    CGContextRef contextRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imageRef = [context createCGImage:CI_QRImage fromRect:extent];
    CGContextSetInterpolationQuality(contextRef, kCGInterpolationNone);
    CGContextScaleCTM(contextRef, scale, scale);
    CGContextDrawImage(contextRef, extent, imageRef);
    
    CGImageRef imageRefResized = CGBitmapContextCreateImage(contextRef);
    
    //Release
    CGContextRelease(contextRef);
    CGImageRelease(imageRef);
    return [UIImage imageWithCGImage:imageRefResized];
}

+ (UIImage *)colorQRCodeImage:(UIImage*)image red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    //Create context
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    //Traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            //Change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    
    //Convert to image
    CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpaceRef,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProviderRef,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProviderRef);
    UIImage* img = [UIImage imageWithCGImage:imageRef];
    
    //Release
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    return img;
}

+ (NSString *)QRCodeString:(UIImage *)QRCodeImg {
    return [CMQRCode QRCodeStringFromCIDetector:QRCodeImg];
}


#pragma mark -
#pragma mark - Private Methods

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

+ (NSString *)QRCodeStringFromCIDetector:(UIImage *)souceImg {
    CIImage *ci_souceImg = [CIImage imageWithCGImage:souceImg.CGImage];
    CIContext *ci_context = [CIContext contextWithOptions:nil];
    CIDetector *ci_detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:ci_context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [ci_detector featuresInImage:ci_souceImg];
    
    if (features.count > 0) {
        return ((CIQRCodeFeature *)(features[0])).messageString;
    }
    return nil;
}

+ (NSString *)QRCodeStringFromZXMultiFormatReader:(UIImage *)souceImg {
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:souceImg.CGImage];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap hints:hints error:&error];
    if (!error && result) {
        return result.text;
    }
    return nil;
}

@end
