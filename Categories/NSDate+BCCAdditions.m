//
//  NSDate+BCCAdditions.m
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import "NSDate+BCCAdditions.h"


static NSCalendar *gregorianCalendar;
static NSDateFormatter *dayOfWeekOnlyFormatter;
static NSDateFormatter *monthOnlyFormatter;
static NSDateFormatter *timeOnlyFormatter;
static NSDateFormatter *veryShortDateFormatter;
static NSDateFormatter *shortDateFormatter;
static NSDateFormatter *longDateFormatter;
static NSDateFormatter *veryLongDateFormatter;

const NSTimeInterval BCCTimeIntervalWeek = 604800.0;



@implementation NSDate (BCCAdditions)

#pragma mark Convenience Date Creation Methods

+ (NSDate *)BCC_dateWithCTimeStruct:(time_t)inTimeStruct
{
    // Convert the time_t to a UTC tm struct
    struct tm* UTCDateStruct = gmtime(&(inTimeStruct));
    
    // Convert the tm struct to date components
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setSecond:UTCDateStruct->tm_sec];
    [dateComponents setMinute:UTCDateStruct->tm_min];
    [dateComponents setHour:UTCDateStruct->tm_hour];
    [dateComponents setDay:UTCDateStruct->tm_mday];
    [dateComponents setMonth:UTCDateStruct->tm_mon + 1];
    [dateComponents setYear:UTCDateStruct->tm_year + 1900];
    
    // Use the date components to create an NSDate object
    NSDate *newDate = [[[NSCalendar currentCalendar] dateFromComponents:dateComponents] dateByAddingTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT]];

    return newDate;
}

#pragma mark Accessors

- (NSInteger)BCC_century
{
    NSInteger currentYear = self.BCC_year;
    NSString *yearStr = [[NSNumber numberWithInteger:currentYear] stringValue];
    
    // in this case, the year is < 100, such as 0 to 99, making it the "0" century
    if (yearStr.length < 3) {
        return 0;
    }
    
    // strip the year off the date
    return [[[yearStr substringToIndex:(yearStr.length - 2)] stringByAppendingString:@"00"] integerValue];
}

- (NSInteger)BCC_decade
{
    // First, get the century - year
    NSInteger decade = self.BCC_year - self.BCC_century;
    
    // this will give us 09 in the case of 2009.  Round down the whole number
    return (decade / 10) * 10;
}

- (NSInteger)BCC_year
{
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:self] year];
}

- (NSInteger)BCC_month
{
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:self] month];
}

#pragma mark Date String Parsing

+ (NSDateFormatter *)BCC_ISO8601DateFormatterConfiguredForTimeZone:(NSTimeZone *)inTimeZone supportingFractionalSeconds:(BOOL)inSupportFractionalSeconds
{
    NSTimeZone *timeZone = inTimeZone;
    if (!timeZone) {
        timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    }

    // Y-MM-dd'T'HH':'MM':'ss'.'SSS'Z
    // Y-MM-dd'T'HH':'MM':'ss'.'SSS'Z'Z
    NSMutableString *formatString = [[NSMutableString alloc] initWithString:@"Y-MM-dd'T'HH':'mm':'ss"];
    if (inSupportFractionalSeconds) {
        [formatString appendString:@"'.'SSS"];
    }

    [formatString appendString:@"'Z'"];
    
    /*if (inTimeZone && ![timeZone isEqualToTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]]) {
        [formatString appendString:@"Z"];
    }*/
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatString];
    [formatter setTimeZone:timeZone];
    
    return formatter;
}

+ (NSDate *)BCC_dateFromISO8601String:(NSString *)inDateString
{
    return [NSDate BCC_dateFromISO8601String:inDateString timeZone:nil supportingFractionalSeconds:NO];
}

+ (NSDate *)BCC_dateFromISO8601String:(NSString *)inDateString timeZone:(NSTimeZone *)inTimeZone supportingFractionalSeconds:(BOOL)inSupportFractionalSeconds;
{
    NSDate *outDate = nil;
    NSString *error = nil;
    [[NSDate BCC_ISO8601DateFormatterConfiguredForTimeZone:inTimeZone supportingFractionalSeconds:inSupportFractionalSeconds] getObjectValue:&outDate forString:inDateString errorDescription:&error];
    
    if (error) {
        NSLog(@"ISO 8601 date parsing error: %@", error);
    }
    
    return outDate;
}

#pragma mark Convenience String Formatting Methods

- (NSString *)BCC_timeIntervalSince1970String
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)ceil([self timeIntervalSince1970])];
}

- (NSString *)BCC_timeString
{
	if (!timeOnlyFormatter) {
        timeOnlyFormatter = [[NSDateFormatter alloc] init];
        [timeOnlyFormatter setDateStyle:NSDateFormatterNoStyle];
        [timeOnlyFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
	return [timeOnlyFormatter stringFromDate:self];
}

- (NSString *)BCC_monthNameString
{
    if (!monthOnlyFormatter) {
        monthOnlyFormatter = [[NSDateFormatter alloc] init];
        [monthOnlyFormatter setDateFormat:@"MMMM"];
    }
    
    return [monthOnlyFormatter stringFromDate:self];
}

- (NSString *)BCC_dayOfWeekString
{
	if (!dayOfWeekOnlyFormatter) {
        dayOfWeekOnlyFormatter = [[NSDateFormatter alloc] init];
        [dayOfWeekOnlyFormatter setDateFormat:@"EEEE"];
    }
    
    return [dayOfWeekOnlyFormatter stringFromDate:self];
}

- (NSString *)BCC_veryShortDateString
{
    if (!veryShortDateFormatter) {
        veryShortDateFormatter = [[NSDateFormatter alloc] init];
        [veryShortDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [veryShortDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    return [veryShortDateFormatter stringFromDate:self];
}

- (NSString *)BCC_shortDateString
{
    if (!shortDateFormatter) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
        [shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [shortDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return [shortDateFormatter stringFromDate:self];
}

- (NSString *)BCC_longDateString
{
    if (!longDateFormatter) {
        longDateFormatter = [[NSDateFormatter alloc] init];
        [longDateFormatter setDateStyle:NSDateFormatterLongStyle];
        [longDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return [longDateFormatter stringFromDate:self];
}

- (NSString *)BCC_veryLongDateString
{
    if (!veryLongDateFormatter) {
        longDateFormatter = [[NSDateFormatter alloc] init];
        [longDateFormatter setDateStyle:NSDateFormatterLongStyle];
        [longDateFormatter setTimeStyle:NSDateFormatterLongStyle];        
    }
    
    return [veryLongDateFormatter stringFromDate:self];
}

- (NSString *)BCC_SMSStyleDateString
{
    if (!gregorianCalendar) {
        gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    
	NSDateComponents *comparisonComponents = [gregorianCalendar components:NSCalendarUnitDay fromDate:self toDate:[NSDate date] options:0];
	NSInteger daysBetween = [comparisonComponents day];
    
    NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitWeekday;
	NSDateComponents *components = [gregorianCalendar components:unitFlags fromDate:self];
	NSDateComponents *nowComponents = [gregorianCalendar components:unitFlags fromDate:[NSDate date]];
	
	NSUInteger day = [components day];
	NSUInteger nowDay = [nowComponents day];
    
	NSString *dateString;
	
	if (day == nowDay) {
		return [self BCC_timeString];
	}
	else if (daysBetween < 2) {
		return NSLocalizedString(@"Yesterday", @"");
	}
	else if (daysBetween < 7 && [components weekday] < [nowComponents weekday]) {
		return [self BCC_dayOfWeekString];
	}
	else {
		return [self BCC_shortDateString];
	}
	
	return dateString;
}

- (NSString *)BCC_relativeDateString
{
    return [self BCC_relativeDateStringWithCutoff:0.0 fullDateFormatter:nil nowText:nil useAbbreviatedUnits:NO];
}

- (NSString *)BCC_relativeDateStringWithCutoff:(NSTimeInterval)cutoff fullDateFormatter:(NSDateFormatter *)fullDateFormatter nowText:(NSString *)nowText useAbbreviatedUnits:(BOOL)abbreviatedUnits
{
    // TO DO: Come up with a better way of handling time in the past vs. present
    // rather than just treating everything as absolute?
    
    // TO DO: Make cutoff work correctly
    
    if (!gregorianCalendar) {
        gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
	
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
	NSDateComponents *components = [gregorianCalendar components:unitFlags fromDate:self toDate:[NSDate date] options:0];
    NSInteger years = labs([components year]);
    NSInteger weeks = labs([components weekOfYear]);
    NSInteger days = labs([components day]);
	NSInteger hours = labs([components hour]);
	NSInteger minutes = labs([components minute]);
	//NSInteger seconds = [components second];
    
//    if (cutoff > 0 && cutoff < fabs([self timeIntervalSinceNow])) {
//        if (fullDateFormatter) {
//            return [fullDateFormatter stringFromDate:self];
//        } else {
//            return [self BCC_veryShortDateString];
//        }
//    }
	
    NSInteger unitAmount = 0;
	NSString *unitDescription = nil;
	
	if (years == 1) {
        unitAmount = 1;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"y", @"") : NSLocalizedString(@"year", @"");
    } if (years > 1) {
        unitAmount = years;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"y", @"") : NSLocalizedString(@"years", @"");
	} else if (weeks == 1) {
        unitAmount = 1;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"w", @"") : NSLocalizedString(@"week", @"");
    } else if (weeks > 1) {
        unitAmount = weeks;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"w", @"") : NSLocalizedString(@"weeks", @"");
	} else if (days == 1) {
        unitAmount = 1;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"d", @"") : NSLocalizedString(@"day", @"");
    } else if (days > 1) {
        unitAmount = days;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"d", @"") : NSLocalizedString(@"days", @"");
	} else if (hours == 1) {
        unitAmount = hours;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"h", @"") : NSLocalizedString(@"hour", @"");
    } else if (hours >= 1) {
        unitAmount = hours;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"h", @"") : NSLocalizedString(@"hours", @"");
	} else if (minutes == 1) {
        unitAmount = minutes;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"m", @"") : NSLocalizedString(@"minute", @"");
	} else if (minutes > 1) {
        unitAmount = minutes;
        unitDescription = abbreviatedUnits ? NSLocalizedString(@"m", @"") : NSLocalizedString(@"minutes", @"");
	} else {
        NSString *defaultNowText = abbreviatedUnits ? NSLocalizedString(@"< 1 m", @"") : NSLocalizedString(@"< 1 minute", @"");
        return nowText ? nowText : defaultNowText;
	}
    
    if (!unitDescription) {
        return nil;
    }
    
	return [NSString stringWithFormat:@"%ld %@", (long)unitAmount, unitDescription];
}

- (NSString *)BCC_HTTPTimeZoneHeaderString
{
    return [self BCC_HTTPTimeZoneHeaderStringForTimeZone:nil];
}

- (NSString *)BCC_HTTPTimeZoneHeaderStringForTimeZone:(NSTimeZone *)inTimeZone
{
    NSTimeZone *timeZone = inTimeZone ? inTimeZone : [NSTimeZone localTimeZone];
    NSString *dateString = [self BCC_ISO8601StringForTimeZone:timeZone];
    NSString *timeZoneHeader = [NSString stringWithFormat:@"%@;;%@", dateString, [timeZone name]];
    return timeZoneHeader;
}

- (NSString *)BCC_ISO8601String;
{
    return [self BCC_ISO8601StringForTimeZone:nil];
}

- (NSString *)BCC_ISO8601StringForLocalTimeZone
{
    return [self BCC_ISO8601StringForTimeZone:[NSTimeZone localTimeZone]];
}

- (NSString *)BCC_ISO8601StringForTimeZone:(NSTimeZone *)inTimeZone
{
    return [self BCC_ISO8601StringForTimeZone:inTimeZone usingFractionalSeconds:NO];
}

- (NSString *)BCC_ISO8601StringForTimeZone:(NSTimeZone *)inTimeZone usingFractionalSeconds:(BOOL)inUseFractionalSeconds
{
    return [[NSDate BCC_ISO8601DateFormatterConfiguredForTimeZone:inTimeZone supportingFractionalSeconds:inUseFractionalSeconds] stringFromDate:self]; 
}

@end
