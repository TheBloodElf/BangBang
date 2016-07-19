/*The MIT License (MIT)
 Copyright (c) 2012 Atipik Sarl
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/

#import "NSCalendar+NSCalendar_Atipik.h"

@implementation NSCalendar (NSCalendar_Atipik)
-(NSDate*) dateFromYear:(NSUInteger) year month:(NSUInteger) month day:(NSUInteger) day{
    NSDateComponents * dc = [[NSDateComponents alloc] init];
    [dc setYear:year];
    [dc setMonth:month];
    [dc setDay:day];
    NSDate* d = [self dateFromComponents:dc];
    return d;
}

-(NSDate*) dateFromYear:(NSUInteger) year month:(NSUInteger) month day:(NSUInteger) day hour:(NSUInteger) hour minute:(NSUInteger) minute{
    NSDateComponents * dc = [[NSDateComponents alloc] init];
    [dc setYear:year];
    [dc setMonth:month];
    [dc setDay:day];
    [dc setHour:hour];
    [dc setMinute:minute];
    NSDate* d = [self dateFromComponents:dc];
    return d;
}


- (NSString*) rruleDateFromDate:(NSDate*) date{
	
	NSDateFormatter * dateFormat = [[NSDateFormatter alloc]init];
	[dateFormat setDateFormat: @"yyyyMMdd'T'HHmmss'Z'"];
	
	
	NSString * dateUpdate =[dateFormat stringFromDate:date];
	/*NSString * part = [dateUpdate substringToIndex:19];
     NSString * part2 = [dateUpdate substringFromIndex:20];
     NSString * part3=nil;
     NSString * part4=nil;
     if ([part2 length]==4) {
     part3 = [part2 substringToIndex:2];
     part4 = [part2 substringFromIndex:2];
     if (part3 && part4) {
     dateUpdate = [NSString stringWithFormat:@"%@+%@:%@",part,part3,part4,nil];
     }
     }*/
	return dateUpdate;
    
}
@end
