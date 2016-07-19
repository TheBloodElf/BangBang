/*The MIT License (MIT)
 Copyright (c) 2012 Atipik Sarl
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/
#import <Foundation/Foundation.h>
#define AKDefaultEncodeKey @"abwabwa"
#define AKDefaultSeparator @"--///--"
@interface NSString (NSString_Atipik)
- (NSString *) md5;
// retourne le chemin ( basedir )
- (NSString *) pathComponent;
- (NSData*) base64Decode;
+ (NSData*) base64Decode:(NSString*) string ;
+ (NSData*) base64Decode:(const char*) string length:(NSInteger) inputLength ;
+ (void) initializeBase64;

+ (NSString*) urlencode: (NSString *) url;
+ (NSString*) urldecode: (NSString *) url;
+ (NSString*) randomStringWithLength: (int) len ;
- (NSString*) urlencode;
- (NSString*) urldecode;

- (NSString*) decodeHash: (NSString*) key;
- (NSString*) decodeHash: (NSString*) key withSeparator:(NSString*)separator;
- (NSString*) encodeHash: (NSString*) key withSeparator:(NSString*)separator;
- (NSString*) encodeHash: (NSString*) key;

- (NSString *)stringByDecodingXMLEntities ;
- (NSString *)stringByEncodingXMLEntities;
- (NSString *)stringByStrippingTags ;
- (NSString *)stringByDecodingTags;
- (NSString *)stringWithNewLinesAsBRs;
- (NSString *)stringByRemovingNewLinesAndWhitespace;
- (NSString *)ellipsisAt:(int) numChars withSuffix:(NSString*) suffix;
- (NSString *)toASCII;

- (NSString *)substringFromChar:(char) from toChar:(char) to;

+ (BOOL) isValidEmail:(NSString *)checkString;

- (NSString *) addSlashes;
- (NSInteger) toInt;
- (NSNumber*) toNumber;
+(NSString*) timeFormat:(CGFloat) interval;
+(NSString*) stringTimeFromDate:(NSDate*) date;

-(NSString*) ucFirst;
@end

@interface NSData (AKStringExtension)
- (NSString*) md5;
- (NSString*) base64Encode;
+ (NSString*) base64Encode:(NSData*) rawBytes ;
+ (NSString*) base64Encode:(const uint8_t*) input length:(NSInteger) length ;
+ (void) initializeBase64;

@end