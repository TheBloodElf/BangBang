//
//  EKRecurrenceRule+RRULE.m
//  RRULE
//
//  Created by Jochen Schöllig on 24.04.13.
//  Copyright (c) 2013 Jochen Schöllig. All rights reserved.
//

#import "EKRecurrenceRule+RRULE.h"

static NSDateFormatter *dateFormatter = nil;

@implementation EKRecurrenceRule (RRULE)

- (EKRecurrenceRule *)initWithString:(NSString *)rfc2445String
{
    // If the date formatter isn't already set up, create it and cache it for reuse.
    if (dateFormatter == nil)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        [dateFormatter setLocale:enUSPOSIXLocale];
        [dateFormatter setDateFormat:@"yyyyMMdd'T'HHmmss'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    // Begin parsing
    NSArray *components = [rfc2445String.uppercaseString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";="]];

    EKRecurrenceFrequency frequency = EKRecurrenceFrequencyDaily;
    NSInteger interval              = 1;
    NSMutableArray *daysOfTheWeek   = nil;
    NSMutableArray *daysOfTheMonth  = nil;
    NSMutableArray *monthsOfTheYear = nil;
    NSMutableArray *daysOfTheYear   = nil;
    NSMutableArray *weeksOfTheYear  = nil;
    NSMutableArray *setPositions    = nil;
    EKRecurrenceEnd *recurrenceEnd  = nil;
    
    for (int i = 0; i < components.count; i++)
    {
        NSString *component = [components objectAtIndex:i];
        
        // Frequency
        if ([component isEqualToString:@"FREQ"])
        {
            NSString *frequencyString = [components objectAtIndex:++i];
            
            if      ([frequencyString isEqualToString:@"DAILY"])   frequency = EKRecurrenceFrequencyDaily;
            else if ([frequencyString isEqualToString:@"WEEKLY"])  frequency = EKRecurrenceFrequencyWeekly;
            else if ([frequencyString isEqualToString:@"MONTHLY"]) frequency = EKRecurrenceFrequencyMonthly;
            else if ([frequencyString isEqualToString:@"YEARLY"])  frequency = EKRecurrenceFrequencyYearly;
        }
    
        // Interval
        if ([component isEqualToString:@"INTERVAL"])
        {
            interval = [[components objectAtIndex:++i] intValue];
        }
        
        // Days of the week
        if ([component isEqualToString:@"BYDAY"])
        {
            daysOfTheWeek = [NSMutableArray array];
            NSArray *dayStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *dayString in dayStrings)
            {
                
                if(dayString && ![dayString isEqualToString:@""] && dayString.length > 0){
                    int dayOfWeek = 0;
                    int weekNumber = 0;
                    
                    // Parse the day of the week
                    if ([dayString rangeOfString:@"SU"].location != NSNotFound)      dayOfWeek = EKSunday;
                    else if ([dayString rangeOfString:@"MO"].location != NSNotFound) dayOfWeek = EKMonday;
                    else if ([dayString rangeOfString:@"TU"].location != NSNotFound) dayOfWeek = EKTuesday;
                    else if ([dayString rangeOfString:@"WE"].location != NSNotFound) dayOfWeek = EKWednesday;
                    else if ([dayString rangeOfString:@"TH"].location != NSNotFound) dayOfWeek = EKThursday;
                    else if ([dayString rangeOfString:@"FR"].location != NSNotFound) dayOfWeek = EKFriday;
                    else if ([dayString rangeOfString:@"SA"].location != NSNotFound) dayOfWeek = EKSaturday;
                    
                    // Parse the week number
                    weekNumber = [[dayString substringToIndex:dayString.length-2] intValue];
                    
                    [daysOfTheWeek addObject:[EKRecurrenceDayOfWeek dayOfWeek:dayOfWeek weekNumber:weekNumber]];
                }
                
            }
        }
        
        // Days of the month
        if ([component isEqualToString:@"BYMONTHDAY"])
        {
            daysOfTheMonth = [NSMutableArray array];
            NSArray *dayStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *dayString in dayStrings)
            {
                [daysOfTheMonth addObject:[NSNumber numberWithInt:dayString.intValue]];
            }
        }
        
        // Months of the year
        if ([component isEqualToString:@"BYMONTH"])
        {
            monthsOfTheYear = [NSMutableArray array];
            NSArray *monthStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *monthString in monthStrings)
            {
                [monthsOfTheYear addObject:[NSNumber numberWithInt:monthString.intValue]];
            }
        }
        
        // Weeks of the year
        if ([component isEqualToString:@"BYWEEKNO"])
        {
            weeksOfTheYear = [NSMutableArray array];
            NSArray *weekStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *weekString in weekStrings)
            {
                [weeksOfTheYear addObject:[NSNumber numberWithInt:weekString.intValue]];
            }
        }
        
        // Days of the year
        if ([component isEqualToString:@"BYYEARDAY"])
        {
            daysOfTheYear = [NSMutableArray array];
            NSArray *dayStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *dayString in dayStrings)
            {
                [daysOfTheYear addObject:[NSNumber numberWithInt:dayString.intValue]];
            }
        }
        
        // Set positions
        if ([component isEqualToString:@"BYSETPOS"])
        {
            setPositions = [NSMutableArray array];
            NSArray *positionStrings = [[components objectAtIndex:++i] componentsSeparatedByString:@","];
            for (NSString *potitionString in positionStrings)
            {
                [setPositions addObject:[NSNumber numberWithInt:potitionString.intValue]];
            }
        }
        
        // RecurrenceEnd
        if ([component isEqualToString:@"COUNT"])
        {
            NSUInteger occurenceCount = [[components objectAtIndex:++i] intValue];
            recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithOccurrenceCount:occurenceCount];
            
        } else if ([component isEqualToString:@"UNTIL"])
        {
            NSDate *endDate =  [dateFormatter dateFromString:[components objectAtIndex:++i]];
            recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithEndDate:endDate];
        }
    }
    
    return [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency
                                                        interval:interval
                                                   daysOfTheWeek:daysOfTheWeek
                                                  daysOfTheMonth:daysOfTheMonth
                                                 monthsOfTheYear:monthsOfTheYear
                                                  weeksOfTheYear:weeksOfTheYear
                                                   daysOfTheYear:daysOfTheYear
                                                    setPositions:setPositions
                                                             end:recurrenceEnd];
}

-(NSString *)rRuleString{
    NSString *fakerRuleStr = self.description;
    NSArray *rruleStr = [fakerRuleStr componentsSeparatedByString:@"RRULE "];
    return rruleStr[1];
}

-(NSString *)rRepeatString{
    NSString *repeatString;
    if (self.frequency == EKRecurrenceFrequencyDaily) {
        if(self.daysOfTheWeek.count == 5){
            repeatString = @"每个工作日";
        }
        else{
            int intervalTemp = (int)self.interval;
            repeatString = [NSString stringWithFormat:@"每%d天",intervalTemp];
        }
    }
    else if (self.frequency == EKRecurrenceFrequencyWeekly){
        if (self.daysOfTheWeek.count > 0) {
            repeatString = [NSString stringWithFormat:@"每%@周的",@(self.interval)];
            for (EKRecurrenceDayOfWeek *obj in self.daysOfTheWeek) {
                if(obj.dayOfTheWeek == EKSunday){
                    repeatString = [repeatString stringByAppendingString:@"周日、"];
                }
                else if(obj.dayOfTheWeek == EKMonday){
                    repeatString = [repeatString stringByAppendingString:@"周一、"];
                }
                else if(obj.dayOfTheWeek == EKTuesday){
                    repeatString = [repeatString stringByAppendingString:@"周二、"];
                }
                else if(obj.dayOfTheWeek == EKWednesday){
                    repeatString = [repeatString stringByAppendingString:@"周三、"];
                }
                else if(obj.dayOfTheWeek == EKThursday){
                    repeatString = [repeatString stringByAppendingString:@"周四、"];
                }
                else if(obj.dayOfTheWeek == EKFriday){
                    repeatString = [repeatString stringByAppendingString:@"周五、"];
                }
                else {
                    repeatString = [repeatString stringByAppendingString:@"周六、"];
                }
            }
            repeatString = [repeatString substringToIndex:[repeatString length]-1];
        }
    }
    else if(self.frequency == EKRecurrenceFrequencyMonthly){
        if (self.daysOfTheMonth.count > 0) {
            repeatString = [NSString stringWithFormat:@"每%@个月的%@号",@(self.interval),self.daysOfTheMonth[0]];
        }
    }
    else if(self.frequency == EKRecurrenceFrequencyYearly){
        if (self.daysOfTheMonth >0 && self.monthsOfTheYear.count >0) {
            repeatString = [NSString stringWithFormat:@"每年的%@月%@日",self.monthsOfTheYear[0],self.daysOfTheMonth[0]];
        }
    }
    return repeatString;
}
@end
