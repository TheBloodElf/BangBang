/*The MIT License (MIT)
 Copyright (c) 2012 Atipik Sarl
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/

#import <Foundation/Foundation.h>

@interface Scheduler : NSObject{
    NSDate * _start_date;
    NSTimeInterval _start_ts;
    
    NSString*   _rrule_freq;
    
    // both count & until are forbidden
   
    NSNumber *   _rrule_until ;
    
    // facultative
    NSInteger   _rrule_interval;
    
    // use for complex
    NSNumber *  _rrule_count ; // facultative
    NSArray*   _rrule_bysecond ;
    NSArray*   _rrule_byminute ;
    NSArray*   _rrule_byhour ;
    NSArray*   _rrule_byday ; // +1, -2, etc. only for monthly or yearly
    NSArray*   _rrule_bymonthday ;
    NSArray*   _rrule_byyearday ;
    NSArray*   _rrule_byweekno ; // only for yearly
    NSArray*   _rrule_bymonth ;
    NSArray*   _rrule_bysetpos ; // only in conjonction with others BYxxx rules
    NSString*   _rrule_wkst;
   
    
    
    NSMutableArray * _exception_dates;
    NSUInteger _current_pos;
    NSMutableArray * _old_pos;
    
    BOOL _rrule_byday_weeklyDefault;
    BOOL _rrule_bymonthday_monthlyDefault;
    BOOL _rrule_bymonthday_yearlyDefault;
    BOOL _rrule_bymonth_yearlyDefault;
    
    
}



#pragma mark -
#pragma mark Properties
@property (nonatomic, copy) NSDate *start_date;
@property (nonatomic) NSTimeInterval start_ts;
@property (nonatomic, copy) NSString *rrule_freq;
@property (nonatomic, copy) NSNumber *rrule_until;
@property (nonatomic) NSInteger rrule_interval;
@property (nonatomic, copy) NSNumber *rrule_count;
@property (nonatomic, copy) NSArray *rrule_bysecond;
@property (nonatomic, copy) NSArray *rrule_byminute;
@property (nonatomic, copy) NSArray *rrule_byhour;
@property (nonatomic, copy) NSArray *rrule_byday;
@property (nonatomic, copy) NSArray *rrule_bymonthday;
@property (nonatomic, copy) NSArray *rrule_byyearday;
@property (nonatomic, copy) NSArray *rrule_byweekno;
@property (nonatomic, copy) NSArray *rrule_bymonth;
@property (nonatomic, copy) NSArray *rrule_bysetpos;
@property (nonatomic, copy) NSString *rrule_wkst;
@property (nonatomic, retain) NSMutableArray *exception_dates;
@property (nonatomic) NSUInteger current_pos;
@property (nonatomic, retain) NSMutableArray *old_pos;
@property (nonatomic, getter=isRrule_byday_weeklyDefault) BOOL rrule_byday_weeklyDefault;
@property (nonatomic, getter=isRrule_bymonthday_monthlyDefault) BOOL rrule_bymonthday_monthlyDefault;
@property (nonatomic, getter=isRrule_bymonthday_yearlyDefault) BOOL rrule_bymonthday_yearlyDefault;
@property (nonatomic, getter=isRrule_bymonth_yearlyDefault) BOOL rrule_bymonth_yearlyDefault;


-(id) initWithDate:(NSDate*)start_date andRule:(NSString*) rrule;
-(void) initReccurenceRules;
-(void) addReccurenceRules:(NSString*) rrule;
-(void) addExceptionDates:(NSArray*) dates;
-(void) removeExceptionDates;
-(NSArray*) allOccurencesSince:(NSNumber*) filter_begin_ts until:(NSNumber*) filter_end_ts;
-(NSDate*) nextPeriod:(NSDate*) date;
-(BOOL) checkRule:(NSDate*) date;

-(NSArray*) occurencesBetween:(NSDate*) start  andDate:(NSDate*) end;

-(BOOL) checkDay:(NSDate*) date;
-(NSArray*) findWeeksDay:(NSNumber*) year :(NSNumber*) month :(NSNumber*) ordinal :(NSString*)week_day;

-(NSString*) dayFromNoDay:(NSInteger) day;
-(NSUInteger) noDayFromDay:(NSString*) day;

#pragma mark - 

-(BOOL) isDaily;
-(BOOL) isWeekly;
-(BOOL) isBiWeekly;
-(BOOL) isMonthly;
-(BOOL) isYearly;
-(BOOL) isComplex;
-(NSString*) getRule;


@end
