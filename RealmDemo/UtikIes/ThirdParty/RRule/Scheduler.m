/*The MIT License (MIT)
 Copyright (c) 2012 Atipik Sarl
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/

#define ALL_DATE_FLAGS NSCalendarUnitWeekday |NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitWeekOfYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
#import "Scheduler.h"
#import "NSArray+Atipik.h"
#import "NSCalendar+NSCalendar_Atipik.h"
@implementation Scheduler
static NSCalendar * calendar=nil;



#pragma mark -
#pragma mark Properties
@synthesize start_date = _start_date;
@synthesize start_ts = _start_ts;
@synthesize rrule_freq = _rrule_freq;
@synthesize rrule_until = _rrule_until;
@synthesize rrule_interval = _rrule_interval;
@synthesize rrule_count = _rrule_count;
@synthesize rrule_bysecond = _rrule_bysecond;
@synthesize rrule_byminute = _rrule_byminute;
@synthesize rrule_byhour = _rrule_byhour;
@synthesize rrule_byday = _rrule_byday;
@synthesize rrule_bymonthday = _rrule_bymonthday;
@synthesize rrule_byyearday = _rrule_byyearday;
@synthesize rrule_byweekno = _rrule_byweekno;
@synthesize rrule_bymonth = _rrule_bymonth;
@synthesize rrule_bysetpos = _rrule_bysetpos;
@synthesize rrule_wkst = _rrule_wkst;
@synthesize exception_dates = _exception_dates;
@synthesize current_pos = _current_pos;
@synthesize old_pos = _old_pos;
@synthesize rrule_byday_weeklyDefault = _rrule_byday_weeklyDefault;
@synthesize rrule_bymonthday_monthlyDefault = _rrule_bymonthday_monthlyDefault;
@synthesize rrule_bymonthday_yearlyDefault = _rrule_bymonthday_yearlyDefault;
@synthesize rrule_bymonth_yearlyDefault = _rrule_bymonth_yearlyDefault;



-(id) initWithDate:(NSDate*)start_date andRule:(NSString*) rfc_rrule{
    if (self = [super init]) {
        self.rrule_wkst =   @"MO";
//        self.start_date = start_date;
//        _start_ts = [start_date timeIntervalSince1970] - 86400;
        
        _start_ts = [start_date timeIntervalSince1970] - 24 * 3600;
        self.start_date = [[NSDate alloc] initWithTimeIntervalSince1970:_start_ts];
        self.exception_dates =[NSMutableArray array];
    //    calendar = [NSCalendar currentCalendar];
        if(!calendar){
            calendar = [NSCalendar currentCalendar];
        }
        [self initReccurenceRules];
        
        if (rfc_rrule) {
            [self addReccurenceRules:rfc_rrule];
        }
        
    }
    return self;
}

-(void) dealloc{
    
    self.start_date = nil;
    self.rrule_freq = nil;
    self.rrule_count = nil;
    self.rrule_until = nil;
    self.rrule_bysecond = nil;
    self.rrule_byminute = nil;
    self.rrule_byhour = nil;
    self.rrule_byday = nil;
    self.rrule_bymonthday = nil;
    self.rrule_byyearday = nil;
    self.rrule_byweekno = nil;
    self.rrule_bymonth = nil;
    self.rrule_bysetpos = nil;
    self.rrule_wkst = nil;
    self.exception_dates = nil;
    self.old_pos = nil;
}
-(void) initReccurenceRules{
    self.rrule_freq = nil;
    self.rrule_byday_weeklyDefault = NO;
    self.rrule_bymonthday_monthlyDefault = NO;
    self.rrule_bymonthday_yearlyDefault = NO;
    self.rrule_bymonth_yearlyDefault = NO;
    // both count & until are forbidden
    self.rrule_count = nil;
    self.rrule_until = nil;
    
    // facultative
    self.rrule_interval = 1;
    self.rrule_bysecond = nil;
    self.rrule_byminute = nil;
    self.rrule_byhour = nil;
    self.rrule_byday = nil; // +1, -2, etc. only for monthly or yearly
    self.rrule_bymonthday = nil;
    self.rrule_byyearday = nil;
    self.rrule_byweekno = nil; // only for yearly
    self.rrule_bymonth = nil;
    self.rrule_bysetpos = nil; // only in conjonction with others BYxxx rules
    self.rrule_wkst = @"MO"; // significant where weekly interval > 1 & where yearly byweekno is specified
    
}

-(void) addReccurenceRules:(NSString*) rfc_rrule {
    rfc_rrule = [rfc_rrule stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange index = [rfc_rrule rangeOfString:@"RRULE:"];
    if(index.location != NSNotFound && index.location == 0){
        rfc_rrule =  [rfc_rrule substringFromIndex:index.length];
    }
    
    NSArray * rules = [rfc_rrule componentsSeparatedByString:@";"];
    NSUInteger nb_rules = [rules count];
    NSNumberFormatter * nf = [[NSNumberFormatter alloc]init];
   // NSLog(@"%@",[rules description]);
     NSDateComponents * dc = [[NSDateComponents alloc] init];
    for (int i = 0; i < nb_rules; i++) {
        if ([rules objectAtIndex:i] && ![[rules objectAtIndex:i] isEqualToString:@""]) {
            
            
            NSArray*  rule = [[rules objectAtIndex:i] componentsSeparatedByString:@"="];
            NSString * rule_value = [rule objectAtIndex:1];
            NSString * rule_name = [rule objectAtIndex:0];
            if([rule_name isEqualToString:@"FREQ"]){
                self.rrule_freq = rule_value;
            }
            if([rule_name isEqualToString:@"UNTIL"]){
                NSString* until = rule_value;
                
               
                
                
                dc.year = [[nf numberFromString:[until substringWithRange:NSMakeRange(0, 4)]]intValue];
                dc.month = [[nf numberFromString:[until substringWithRange:NSMakeRange(4, 2)]]intValue];
                dc.day = [[nf numberFromString:[until substringWithRange:NSMakeRange(6, 2)]]intValue];
                if( [until length] > 8){
                    dc.hour = [[nf numberFromString:[until substringWithRange:NSMakeRange(9, 2)]]intValue];
                    dc.minute = [[nf numberFromString:[until substringWithRange:NSMakeRange(11, 2)]]intValue];
                    dc.second = [[nf numberFromString:[until substringWithRange:NSMakeRange(13, 2)]]intValue];
                }
                NSDate * d =[calendar dateFromComponents:dc] ;
                self.rrule_until = [NSNumber numberWithFloat:[d timeIntervalSince1970]];
                
                
                
            }
            
            if ([rule_name isEqualToString:@"COUNT"]) {
                self.rrule_count = [nf numberFromString:rule_value];
            }
            
            if ([rule_name isEqualToString:@"INTERVAL"]) {
                self.rrule_interval = [[nf numberFromString:rule_value]intValue];
            }
            if ([rule_name isEqualToString:@"BYSECOND"]) {
                if([rule_value isEqualToString:@""] || !rule_value){
                    self.rrule_bysecond = nil;
                }else{
                    self.rrule_bysecond = [rule_value componentsSeparatedByString:@","];
                }
            }
            if ([rule_name isEqualToString:@"BYMINUTE"]) {
                if([rule_value isEqualToString:@""] || !rule_value){
                    self.rrule_byminute = nil;
                }else{
                    self.rrule_byminute= [rule_value componentsSeparatedByString:@","];
                }
            }
            if ([rule_name isEqualToString:@"BYHOUR"]) {
                if([rule_value isEqualToString:@""] || !rule_value){
                    self.rrule_byhour = nil;
                }else{
                    self.rrule_byhour= [rule_value componentsSeparatedByString:@","];
                }
            }
            if ([rule_name isEqualToString:@"BYDAY"]) {
                if([rule_value isEqualToString:@""] || !rule_value){
                    self.rrule_byday = nil;
                }else{
                    self.rrule_byday= [rule_value componentsSeparatedByString:@","];
                }
            }
            if ([rule_name isEqualToString:@"BYMONTHDAY"]) {
                if(![self.rrule_freq isEqualToString:@"WEEKLY"]){
                    if([rule_value isEqualToString:@""] || !rule_value){
                        self.rrule_bymonthday = nil;
                    }else{
                        self.rrule_bymonthday= [rule_value componentsSeparatedByString:@","];
                    }
                }
            }
            if ([rule_name isEqualToString:@"BYYEARDAY"]) {
                if(![self.rrule_freq isEqualToString:@"YEARLY"]){
                    if([rule_value isEqualToString:@""] || !rule_value){
                        self.rrule_byyearday = nil;
                    }else{
                        self.rrule_byyearday= [rule_value componentsSeparatedByString:@","];
                    }
                }
            }
            if ([rule_name isEqualToString:@"BYWEEKNO"]) {
                if(![self.rrule_freq isEqualToString:@"YEARLY"]){
                    if([rule_value isEqualToString:@""] || !rule_value){
                        self.rrule_byweekno = nil;
                    }else{
                        self.rrule_byweekno= [rule_value componentsSeparatedByString:@","];
                    }
                }
            }
            if ([rule_name isEqualToString:@"BYMONTH"]) {
                if([rule_value isEqualToString:@""] || !rule_value){
                    self.rrule_bymonth = nil;
                }else{
                    self.rrule_bymonth= [rule_value componentsSeparatedByString:@","];
                }
            }
            if ([rule_name isEqualToString:@"BYSETPOS"]) {
                if([rule_value isEqualToString:@""] || !rule_value){
                    self.rrule_bysetpos = nil;
                }else{
                    self.rrule_bysetpos= [rule_value componentsSeparatedByString:@","];
                }
            }
            if ([rule_name isEqualToString:@"WKST"]) {
                self.rrule_wkst= rule_value;
            }
        }
    }
    
    //  NSDateComponents * dc = [[NSDateComponents alloc] init];
    
    if(!self.rrule_bysecond){
        
        self.rrule_bysecond = [NSArray arrayWithObject: 
                               [NSString stringWithFormat:@"%ld",
                                
                                (long)[calendar components:NSCalendarUnitSecond fromDate:self.start_date].second
                                ,
                                nil]
                               
                               ];
    }
    
    if(!self.rrule_byminute){
        
        self.rrule_byminute = [NSArray arrayWithObject: 
                               [NSString stringWithFormat:@"%ld",
                                
                                (long)[calendar components:NSCalendarUnitMinute fromDate:self.start_date].minute
                                ,
                                nil]
                               
                               ];
    }
    
    if(!self.rrule_byhour){
        
        self.rrule_byhour = [NSArray arrayWithObject: 
                             [NSString stringWithFormat:@"%ld",
                              
                              (long)[calendar components:NSCalendarUnitHour fromDate:self.start_date].hour
                              ,
                              nil]
                             
                             ];
    }
    
    if(!self.rrule_byday && [self.rrule_freq isEqualToString:@"WEEKLY"]){
        self.rrule_byday_weeklyDefault = YES;
    //     NSLog(@"%d",[calendar components:NSWeekdayCalendarUnit fromDate:self.start_date].weekday);
        self.rrule_byday = [NSArray arrayWithObject: 
                           
                            [self dayFromNoDay:[calendar components:NSCalendarUnitWeekday fromDate:self.start_date].weekday]
                            ];
     //   NSLog(@"%@",[self.rrule_byday description]);
    }
    
    if(!self.rrule_byday && ! self.rrule_bymonthday && !self.rrule_byyearday && ([self.rrule_freq isEqualToString:@"MONTHLY"] || [self.rrule_freq isEqualToString:@"YEARLY"])){
        
        self.rrule_bymonthday_monthlyDefault = YES;
        self.rrule_bymonthday_yearlyDefault = YES;
        
        self.rrule_bymonthday = [NSArray arrayWithObject: 
                                 [NSString stringWithFormat:@"%ld",
                                  
                                  (long)[calendar components:NSCalendarUnitDay fromDate:self.start_date].day
                                  ,
                                  nil]
                                 
                                 ];
       // NSLog(@"%@",self.rrule_bymonthday);
    }
    
    if (!self.rrule_byday && !self.rrule_byyearday && !self.rrule_bymonth && [self.rrule_freq isEqualToString:@"YEARLY"]) {
        self.rrule_bymonth_yearlyDefault = YES;
        self.rrule_bymonth =  [NSArray arrayWithObject: 
                               [NSString stringWithFormat:@"%ld",
                                
                                (long)[calendar components:NSCalendarUnitMonth fromDate:self.start_date].month
                                ,
                                nil]
                               
                               ];
    }
    
}

-(void) addExceptionDates:(NSArray*) dates{
    /* var nb_date = dates.length;
     for (var i = 0; i < nb_date; i++) {
     this.exception_dates.push(dates[i].getTime());
     }
     this.exception_dates.sort();*/
    NSInteger nb_date = [dates count];
    for (int i =0 ; i< nb_date; i++) {
        [self.exception_dates addObject:[NSNumber numberWithFloat:[[dates objectAtIndex:i] timeIntervalSince1970]]];
    }
}

-(void) removeExceptionDates{
    [self.exception_dates removeAllObjects];
}


-(BOOL) checkRule:(NSDate*) date{
    NSString * day = [self dayFromNoDay:  
                      [calendar components:NSCalendarUnitWeekday fromDate:date].weekday];
    
    NSUInteger d =   [calendar components:NSCalendarUnitDay fromDate:date].day;
    NSUInteger m =   [calendar components:NSCalendarUnitMonth fromDate:date].month;
   /* NSUInteger y =   [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:date].year;
    NSUInteger week_no = [[NSCalendar currentCalendar] components:NSWeekOfYearCalendarUnit fromDate:date].weekOfYear;
    NSUInteger h =   [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:date].hour;
    NSUInteger min =   [[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:date].minute;
    NSUInteger s =   [[NSCalendar currentCalendar] components:NSSecondCalendarUnit fromDate:date].second;
    */if ([self.rrule_freq isEqualToString:@"DAILY"]) {
        return ((!self.rrule_bymonth || [self.rrule_bymonth containsObject:[NSString stringWithFormat:@"%lu",(unsigned long)m,nil]]) &&
                (!self.rrule_bymonthday || [self.rrule_bymonthday containsObject:[NSString stringWithFormat:@"%lu",(unsigned long)d,nil]]) &&
                (!self.rrule_byday || [self.rrule_byday containsObject:day])
                );
    }
    if ([self.rrule_freq isEqualToString:@"WEEKLY"]) {
        return ((!self.rrule_bymonth || [self.rrule_bymonth containsObject:[NSString stringWithFormat:@"%lu",(unsigned long)m,nil]]) &&
                (!self.rrule_bymonthday || [self.rrule_bymonthday containsObject:[NSString stringWithFormat:@"%lu",(unsigned long)d,nil]])
                );
    }
    if ([self.rrule_freq isEqualToString:@"MONTHLY"]) {
        return ((!self.rrule_bymonth || [self.rrule_bymonth containsObject:[NSString stringWithFormat:@"%lu",(unsigned long)m,nil]])
                
                );
    }
    if ([self.rrule_freq isEqualToString:@"YEARLY"]) {
        return YES;
    } 
    return NO;
}

-(BOOL) checkDay:(NSDate*) date{
   
   
   
    NSDateComponents * dc = [calendar components:ALL_DATE_FLAGS fromDate:date];
    
    NSUInteger d =   dc.day;
    NSUInteger m =   dc.month;
    NSUInteger y =   dc.year;
    
    NSString * day = [self dayFromNoDay:dc.weekday];
   // NSUInteger week_no = [calendar components:NSWeekOfYearCalendarUnit fromDate:date].weekOfYear;
    
    
    if(self.rrule_bymonth){
        //  NSLog(@"%@",self.rrule_bymonth);
        if(![self.rrule_bymonth containsObject:[NSString stringWithFormat:@"%lu",(unsigned long)m,nil]]){
            return NO;
        }
    }
     BOOL is_weekly = [self.rrule_freq isEqualToString:@"WEEKLY"];
    if(self.rrule_byday){
        //   NSLog(@"%@",[self.rrule_byday description]);
        if(is_weekly){
            if(![self.rrule_byday containsObject:day]){
                return NO;
            }
        } else {
            //     NSLog(@"%@",[self.rrule_byday description]);
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([A-Z]+)"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            
            BOOL found = NO;
            for (int it_wd = 0; it_wd < [self.rrule_byday count]; it_wd++) {
                NSTextCheckingResult *matchesInString = [regex firstMatchInString:[self.rrule_byday objectAtIndex:it_wd]
                                                       options:0
                                                         range:NSMakeRange(0, [[self.rrule_byday objectAtIndex:it_wd] length])];
                
                NSRange range = [matchesInString range];
                NSNumber* str_number=[NSNumber numberWithInt:0];
                NSString* str_day=@"";
                if (range.location != 0 && range.location != NSNotFound) {
                    NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
                    str_number = [nf numberFromString:[[self.rrule_byday objectAtIndex:it_wd] substringToIndex:range.location]];
                    str_day = [[self.rrule_byday objectAtIndex:it_wd] substringFromIndex:range.location];
                }else{
                    str_day = [self.rrule_byday objectAtIndex:it_wd];
                }
                
                //  NSLog(@"%@ %@",str_number,str_day);
                NSArray * matching_dates = [self findWeeksDay:[NSNumber numberWithInt:(int)y] :[NSNumber numberWithInt:(int)m] :str_number :str_day];
                //     NSLog(@"%@",[matching_dates description]);
                for (int it=0; it < [matching_dates count]; it++) {
                    if ([[matching_dates objectAtIndex:it]isEqualToDate:date]) {
                        found = YES;
                        break;
                    }
                }
                
                
            }
            if(!found){
                return NO;
            }
        }
    }
    
    if(!is_weekly){
        if(self.rrule_bymonthday){
            
            NSDateComponents * dc = [[NSDateComponents alloc] init];
            
            [dc setMonth:m];
            
            NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                                               inUnit:NSCalendarUnitMonth
                                                              forDate:[calendar dateFromComponents:dc]];
            //   NSLog(@"%d", range.length);
            
            NSUInteger month_days_count = range.length;
            NSInteger d_neg = d - 1 - month_days_count;
            BOOL found =NO;
            for (int it_md=0; it_md < [self.rrule_bymonthday count]; it_md++) {
                int md = [[self.rrule_bymonthday objectAtIndex:it_md]  intValue];
                
                if(d==md || d_neg == md){
                    found = YES;
                    break;
                }
            }
            if(!found){
                return NO;
            }
        }
        
    } 
    
    BOOL is_yearly = [self.rrule_freq isEqualToString:@"YEARLY"];
    
    if(is_yearly){
        if (self.rrule_byyearday) {
  //          BOOL found = NO;
            NSDateComponents * dc =[[NSDateComponents alloc] init];
            for (int it_yd= 0; it_yd < [self.rrule_byyearday count] ; it_yd++) {
                int year_day = [[self.rrule_byyearday objectAtIndex:it_yd] intValue];
                if (year_day > 0) {
                   
                    dc.year = y ;
                    dc.weekdayOrdinal = 200;
                    
                 //   NSDate * year_date=[calendar dateFromComponents:dc];
                }
            }
        }
    }
    return YES;
}


-(NSDate*) nextPeriod:(NSDate*) date{
    NSDateComponents * dc = [[NSDateComponents alloc] init];//[[NSCalendar currentCalendar] components:ALL_DATE_FLAGS fromDate:date];
    if([self.rrule_freq isEqualToString:@"DAILY"]){
        
        dc.day =1;
    }
    if([self.rrule_freq isEqualToString:@"WEEKLY"]){
        
        dc.weekOfYear =1;
    }
    if([self.rrule_freq isEqualToString:@"MONTHLY"]){
        
        dc.month =1;
    }
    if([self.rrule_freq isEqualToString:@"YEARLY"]){
        
        dc.year =1;
    }
    
    NSDate * d =  [calendar dateByAddingComponents:dc toDate:date options:0];
    return d;
}

-(NSArray*) occurencesBetween:(NSDate*) start  andDate:(NSDate*) end{
    //这里前后要多加一天来计算，防止漏算
    return [self allOccurencesSince:
            [NSNumber numberWithFloat:
             ([start timeIntervalSince1970] - 24*3600)
             ] 
                              until:
            [NSNumber numberWithFloat:
             [end timeIntervalSince1970] + 24*3600
             ]
            ];
}

-(NSArray*) allOccurencesSince:(NSNumber*) filter_begin_ts until:(NSNumber*) filter_end_ts{
    NSMutableArray* occurences = [NSMutableArray array];
    if ((filter_begin_ts ==nil || filter_end_ts == nil) &&
        self.rrule_count == nil && self.rrule_until == nil) { 
        return nil; // infinity of results => must be processed with filter_begin_ts & filter_end_ts
    }
    
    NSDate * current_date = self.start_date;
    NSUInteger count = 0;
    NSUInteger count_period = 0;

     NSDateComponents * dc = [[NSDateComponents alloc]init];
    BOOL dobreak=NO;

    while (!dobreak && (!self.rrule_count || count < [self.rrule_count intValue])
           && (!self.rrule_until || [current_date timeIntervalSince1970] <= [self.rrule_until floatValue])
           && (!filter_end_ts || [current_date timeIntervalSince1970] <= [filter_end_ts floatValue])
           ){
        
        NSDateComponents * current_date_components = [calendar components:ALL_DATE_FLAGS fromDate:current_date];
        
        NSUInteger d        =       current_date_components.day;
        NSUInteger m        =       current_date_components.month;
        NSUInteger y        =       current_date_components.year;

        self.current_pos = 1;
        self.old_pos = [NSMutableArray array];
        
        if(count_period % self.rrule_interval ==0 && [self checkRule:current_date]){
            if ([self.rrule_freq isEqualToString:@"DAILY"]) {
                             
                for (int h_it = 0; !dobreak  && h_it < [self.rrule_byhour count]; h_it++) {
                    for(int min_it = 0 ;!dobreak  &&  min_it < [self.rrule_byminute count];min_it++){
                        for(int s_it = 0 ;!dobreak  &&  s_it < [self.rrule_byminute count];s_it++){
                           
                            [dc setYear:y];
                            [dc setMonth:m];
                            [dc setDay:d];
                            [dc setHour:[[self.rrule_byhour objectAtIndex:h_it]  intValue]];
                            [dc setMinute:[[self.rrule_byminute objectAtIndex:min_it]  intValue]];
                            [dc setSecond:[[self.rrule_bysecond objectAtIndex:s_it]  intValue]];
                            NSDate * date_to_push = [calendar dateFromComponents:dc];
                            NSTimeInterval ts_to_push = [date_to_push timeIntervalSince1970];
                           
                            
                            if(self.rrule_bysetpos !=nil && [self.rrule_bysetpos containsObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.current_pos,nil]]){
                                self.current_pos++;
                                [self.old_pos addObject:date_to_push];
                                continue;
                            }
                            if((self.rrule_until !=nil && ts_to_push > [self.rrule_until floatValue]) ||
                               (filter_end_ts != nil && ts_to_push > [filter_end_ts floatValue])){
                               // goto period_loop;
                                dobreak=YES;
                                break;
                            }
                            if (ts_to_push >= _start_ts) {
                                if(filter_begin_ts ==nil || ts_to_push >= [filter_begin_ts floatValue]){
                                    [occurences addObject:date_to_push];
                                }
                                count++;
                            }
                            self.current_pos++;
                            [self.old_pos addObject:date_to_push];
                            if(self.rrule_count != nil && count > [self.rrule_count intValue]){
                           //     goto period_loop;
                                dobreak = YES;
                                break;
                            }
                            
                        }
                    }
                }
            }else{
                NSDate * period_begin=nil;
                NSDate * until = nil;
                
                if([self.rrule_freq isEqualToString:@"WEEKLY"]){
                    [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth startDate:&period_begin
                                                     interval:NULL forDate: current_date];
                    dc.weekOfYear =1;
                    until =[calendar dateByAddingComponents:dc toDate:period_begin options:0];
                }
                
                if([self.rrule_freq isEqualToString:@"MONTHLY"]){
                    [dc setDay:1];
                    [dc setMonth:m];
                    [dc setYear:y];
                    period_begin = [calendar dateFromComponents:dc];
                    [dc setMonth:m+1];
                    until = [calendar dateFromComponents:dc];
                } 
                
                if([self.rrule_freq isEqualToString:@"YEARLY"]){
                    [dc setDay:1];
                    [dc setMonth:1];
                    [dc setYear:y];
                    period_begin = [calendar dateFromComponents:dc];
                    [dc setYear:y+1];
                    until = [calendar dateFromComponents:dc];
                }
                
                NSDate * it_date = period_begin;
                while ([it_date timeIntervalSince1970] < [until timeIntervalSince1970]) {
                    NSTimeInterval it_date_ts = [it_date timeIntervalSince1970];
                    if ((self.rrule_until && it_date_ts > [self.rrule_until floatValue])||
                        (filter_end_ts && it_date_ts > [filter_end_ts floatValue])
                        ) 
                    {
                      //  goto period_loop;
                        break;
                    }
                  //  BOOL dobreak = NO;
                    if([self checkDay:it_date]){
                        for (int h_it = 0;!dobreak &&  h_it < [self.rrule_byhour count]; h_it++) {
                            for(int min_it = 0 ;!dobreak && min_it < [self.rrule_byminute count];min_it++){
                                for(int s_it = 0 ;!dobreak &&  s_it < [self.rrule_byminute count];s_it++){
                                    NSDateComponents * dc =[calendar components:ALL_DATE_FLAGS fromDate:it_date];
                                    [dc setHour:[[self.rrule_byhour objectAtIndex:h_it]  intValue]];
                                    [dc setMinute:[[self.rrule_byminute objectAtIndex:min_it]  intValue]];
                                    [dc setSecond:[[self.rrule_bysecond objectAtIndex:s_it]  intValue]];
                                    NSDate * date_to_push = [calendar dateFromComponents:dc];
                                    NSTimeInterval ts_to_push = [date_to_push timeIntervalSince1970];
                                    if(self.rrule_bysetpos && [self.rrule_bysetpos containsObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.current_pos,nil]]){
                                        self.current_pos++;
                                        [self.old_pos addObject:date_to_push];
                                        continue;
                                    }
                                    if ((self.rrule_until && ts_to_push > [self.rrule_until floatValue]) ||
                                        (filter_end_ts && ts_to_push > [filter_end_ts floatValue])) {
                                       // goto period_loop;
                                        dobreak = YES;
                                        break;
                                    }
                                    if (ts_to_push >= _start_ts) {
                                        if (!filter_begin_ts ||  ts_to_push>= [filter_begin_ts floatValue]) {
                                            [occurences addObject:date_to_push];
                                        }
                                        count++;
                                    }
                                    
                                    self.current_pos++;
                                    [self.old_pos addObject:date_to_push];
                                    
                                    if (self.rrule_count && count >= [self.rrule_count intValue]) {
                                       // goto period_loop;
                                        dobreak =YES;
                                        break;
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    
                    NSDateComponents * dd =[calendar components:ALL_DATE_FLAGS fromDate:it_date];
                    
                    dd.day +=1;
                    it_date = [calendar dateFromComponents:dd];
                    
                    
                }
                
                if ([self.rrule_bysetpos isKindOfClass:[NSArray class]]) {
                    for (int it_pos = 0; it_pos < [self.rrule_bysetpos count]; it_pos++) {
                        int pos = [[self.rrule_bysetpos objectAtIndex:it_pos] intValue];
                        if (pos < 0) {
                            pos = abs(pos);
                            NSArray * last_matching_dates = [self.old_pos reverse];
                            NSDate * matching_date = [last_matching_dates objectAtIndex:pos-1];
                            if (matching_date && [matching_date timeIntervalSince1970] >= _start_ts) {
                                [occurences addObject:matching_date];
                                count ++;
                            }
                            if (self.rrule_count && count >= [self.rrule_count intValue]) {
                               // goto period_loop;
                                break ;
                            }
                        }
                    }
                }
                
                
            }
        }
        
        count_period++;
		current_date = [self nextPeriod:current_date];
    }
    
     NSMutableArray * occurrences_without_exdates = [NSMutableArray array];
//period_loop:
    
    /*
     // removes exdates
     var nb_occurrences = occurrences.length;
     var occurrences_without_exdates = [];
     for (var i = 0; i < nb_occurrences; i++) {
        var occurrence = occurrences[i];
        var ts = occurrence.getTime();
        if (!(this.exception_dates.in_array(ts))) {
            occurrences_without_exdates.push(this.test_mode ? ts : occurrence);
        }
     }
     return occurrences_without_exdates;
     
     */
    
//    NSLog(@"%@",[occurences description]);

  //  NSLog(@"%@",[self.exception_dates description]);
    
    
    
   
  //  NSLog(@"%@",[self.exception_dates description]);
    for (int i =0; i<[occurences count]; i++) {
        NSDate * occurence = [occurences objectAtIndex:i];
        NSNumber * ts = [NSNumber numberWithFloat:[occurence timeIntervalSince1970]];
   //     NSLog(@"%@ , %d",[occurence description],[ts intValue]);
        if (![self.exception_dates containsObject:ts]) {
            [occurrences_without_exdates addObject:occurence];
        }
    }
    
    return occurrences_without_exdates;
}
-(NSArray*) findWeeksDay:(NSNumber*) year :(NSNumber*) month :(NSNumber*) ordinal :(NSString*)week_day{
    NSUInteger week_day_n = [self noDayFromDay:week_day];
    NSMutableArray* dates = [NSMutableArray array];
    //if only year is specified returning each month occurence 
    // if ordinal is == 0 return all occurences
 //   NSLog(@"%d %d",week_day_n, [ordinal intValue]);
    
    
   // NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
     
   /* if(year){
        dateComponents.year = [year intValue]; // set the current year or whatever year you want here
    }
    if(month){
        dateComponents.month = [month intValue];
    }
     dateComponents.weekday = week_day_n; // sunday is 1, monday is 2, ...
     dateComponents.weekdayOrdinal = [ordinal intValue]; // this means, the first of whatever weekday you specified
     
    NSLog(@"%@",[calendar dateFromComponents:dateComponents]);
    */
    int count = 0;
    if([ordinal intValue] >=0){
        if (!month) {
            
        }else{
            
            NSDateComponents * dc = [[NSDateComponents alloc] init];
            [dc setYear:[year intValue]];
            [dc setMonth:[month intValue]];
            dc.weekday = week_day_n; 
            NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                           inUnit:NSCalendarUnitMonth
                                          forDate:[calendar dateFromComponents:dc]];
            //   NSLog(@"%d", range.length);
            
            NSUInteger month_days_count = range.length;
            CGFloat b = ceil(month_days_count / 7.0f);
          //  NSLog(@"%f",b);
            NSUInteger z = ((int) b- [ordinal intValue])+1;
            if( [ordinal intValue] == 0){
            for (int i = 1 ; i < z; i++) {
                dc.weekdayOrdinal = [ordinal intValue]+i; // this means, the first of whatever weekday you specified
                NSDate * date = [calendar dateFromComponents:dc];
                [dates addObject:date];
            //     NSLog(@"%@",[calendar dateFromComponents:dc]);
            }
            }else{
                dc.weekdayOrdinal = [ordinal intValue];
                NSDate * date = [calendar dateFromComponents:dc];
                [dates addObject:date];
             //    NSLog(@"%@",[calendar dateFromComponents:dc]);
            }
            
            //  NSDateComponents * dc = [[NSDateComponents alloc] init];
         /*   dc.year = [year intValue];
            dc.month = [month intValue];
            dc.day = 1;
            NSDate * date = [calendar dateFromComponents:dc];
            dc.month = [month intValue]+1;
            
            NSTimeInterval end_month_ts = [[calendar dateFromComponents:dc] timeIntervalSince1970];
            [dc release];
            while ([date timeIntervalSince1970] < end_month_ts) {
                dc = [calendar components:ALL_DATE_FLAGS fromDate:date];
                if (dc.weekday == week_day_n) {
                    count++;
                    if ([ordinal intValue] == 0 || count == [ordinal intValue]) {
                //        [dates addObject:date];
                          NSLog(@"2: %@",date);
                    }
                }
                dc.day+=1;
                date = [calendar dateFromComponents:dc];
              
            }*/
            
           //   [dc release];
           
        }
        
    }else{
        if(!month){
            
        }else{
            
            
            
            NSUInteger nth = abs([ordinal intValue]);
            NSDate * date = [calendar dateFromYear:[year intValue] month:[month intValue]+1 day:0];
            NSTimeInterval begin_month_ts = [[calendar dateFromYear:[year intValue] month:[month intValue] day:1] timeIntervalSince1970];
            count = 0;
            
            while ([date timeIntervalSince1970] >= begin_month_ts) {
                NSDateComponents * dc = [calendar components:ALL_DATE_FLAGS fromDate:date];;
                if (dc.weekday == week_day_n) {
                    count++;
                    if (nth == 0 || count == nth) {
                        [dates addObject:date];
                    }
                }
                dc.day-=1;
                date = [calendar dateFromComponents:dc];
            }
            
        }
    }
   // NSLog(@"%@",dates);
    return dates;
}

-(NSString*) dayFromNoDay:(NSInteger) day{
    switch (day) {
        case 1:
            return @"SU";
            break;
        case 2:
            return @"MO";
            break;
        case 3:
            return @"TU";
            break;
        case 4:
            return @"WE";
            break;
        case 5:
            return @"TH";
            break;
        case 6:
            return @"FR";
            break;
        case 7:
            return @"SA";
            break;
            
        default:
            break;
    }
    return nil;
}
-(NSUInteger) noDayFromDay:(NSString*) day{
    if ([day isEqualToString:@"SU"]) {
        return 1;
    }
    if ([day isEqualToString:@"MO"]) {
        return 2;
    }
    if ([day isEqualToString:@"TU"]) {
        return 3;
    }
    if ([day isEqualToString:@"WE"]) {
        return 4;
    }
    if ([day isEqualToString:@"TH"]) {
        return 5;
    }
    if ([day isEqualToString:@"FR"]) {
        return 6;
    }
    if ([day isEqualToString:@"SA"]) {
        return 7;
    }
    return 0;
}

-(BOOL) isDaily{
    return ([self.rrule_freq isEqualToString:@"DAILY"] && ![self isComplex] && (self.rrule_interval == 1));
}
-(BOOL) isWeekly{
    return ([self.rrule_freq isEqualToString:@"WEEKLY"] && ![self isComplex] && (self.rrule_interval == 1));
}
-(BOOL) isBiWeekly{
    return ([self.rrule_freq isEqualToString:@"WEEKLY"] && ![self isComplex] && (self.rrule_interval == 2));
}
-(BOOL) isMonthly{
    return ([self.rrule_freq isEqualToString:@"MONTHLY"] && ![self isComplex] && (self.rrule_interval == 1));
}
-(BOOL) isYearly{
    return ([self.rrule_freq isEqualToString:@"YEARLY"] && ![self isComplex] && (self.rrule_interval == 1));
}

-(BOOL) isComplex{
    return (self.rrule_count /*|| self.rrule_bysecond || self.rrule_byminute || self.rrule_byhour */|| (self.rrule_byday && [self.rrule_byday count]>0  && !self.rrule_byday_weeklyDefault)  || (self.rrule_bymonthday && [self.rrule_bymonthday count]>0 && !self.rrule_bymonthday_yearlyDefault) || self.rrule_byyearday || self.rrule_byweekno || (self.rrule_bymonth && [self.rrule_bymonth count]>0 && !self.rrule_bymonth_yearlyDefault) || self.rrule_bysetpos );
}

-(NSString*) getRule{
    NSString * rule = @"";
    
    if(self.rrule_freq){
        rule = [rule stringByAppendingFormat:@"FREQ=%@;",self.rrule_freq,nil];
    }
    
    if(self.rrule_until){
        rule = [rule stringByAppendingFormat:@"UNTIL=%@;",[calendar rruleDateFromDate:[NSDate dateWithTimeIntervalSince1970:[self.rrule_until intValue]]],nil];
    }
    
    if(self.rrule_interval && self.rrule_interval > 1){
        rule = [rule stringByAppendingFormat:@"INTERVAL=%ld;",(long)self.rrule_interval,nil];
    }
    
    if(self.rrule_count){
        rule = [rule stringByAppendingFormat:@"COUNT=%d;",[self.rrule_count intValue],nil];
    }
 /*   
    if(self.rrule_bysecond){
        rule = [rule stringByAppendingFormat:@"BYSECOND=%@;",[self.rrule_bysecond componentsJoinedByString:@","],nil];
    }
    
    if(self.rrule_byminute){
        rule = [rule stringByAppendingFormat:@"BYMINUTE=%@;",[self.rrule_byminute componentsJoinedByString:@","],nil];
    }
    
    if(self.rrule_byhour){
        rule = [rule stringByAppendingFormat:@"BYHOUR=%@;",[self.rrule_byhour componentsJoinedByString:@","],nil];
    }*/
    
    if(self.rrule_byday && [self.rrule_byday count]>0){
        rule = [rule stringByAppendingFormat:@"BYDAY=%@;",[self.rrule_byday componentsJoinedByString:@","],nil];
    }
    
    if(self.rrule_bymonthday){
        rule = [rule stringByAppendingFormat:@"BYMONTHDAY=%@;",[self.rrule_bymonthday componentsJoinedByString:@","],nil];
    }
    
    if(self.rrule_byyearday){
        rule = [rule stringByAppendingFormat:@"BYYEARDAY=%@;",[self.rrule_byyearday componentsJoinedByString:@","],nil];
    }
    
    if(self.rrule_byweekno){
        rule = [rule stringByAppendingFormat:@"BYWEEKNO=%@;",[self.rrule_byweekno componentsJoinedByString:@","],nil];
    }
    
    if(self.rrule_bymonth){
        rule = [rule stringByAppendingFormat:@"BYMONTH=%@;",[self.rrule_bymonth componentsJoinedByString:@","],nil];
    }
    
    if(self.rrule_bysetpos){
        rule = [rule stringByAppendingFormat:@"BYSETPOS=%@;",[self.rrule_bysetpos componentsJoinedByString:@","],nil];
    }
    
    if(![self.rrule_wkst isEqualToString:@"MO"]){
        rule = [rule stringByAppendingFormat:@"WKST=%@;",self.rrule_wkst,nil];
    }
    
    return rule;
    
}

@end
