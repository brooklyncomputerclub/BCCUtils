//
//  NSDate+BCCAdditions.h
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "time.h"

extern const NSTimeInterval BCCTimeIntervalWeek;


@interface NSDate (BCCAdditions)

@property (nonatomic, readonly) NSInteger BCC_century;
@property (nonatomic, readonly) NSInteger BCC_decade;
@property (nonatomic, readonly) NSInteger BCC_year;
@property (nonatomic, readonly) NSInteger BCC_month;

// Convenience Date Creation Methods
+ (NSDate *)BCC_dateWithCTimeStruct:(time_t)inTimeStruct;

// Convenience Date Formatter Methods
+ (NSDateFormatter *)BCC_ISO8601DateFormatterConfiguredForTimeZone:(NSTimeZone *)inTimeZone supportingFractionalSeconds:(BOOL)inSupportFractionalSeconds;

// Fixed String Parsing
+ (NSDate *)BCC_dateFromISO8601String:(NSString *)inDateString;
+ (NSDate *)BCC_dateFromISO8601String:(NSString *)inDateString timeZone:(NSTimeZone *)inTimeZone supportingFractionalSeconds:(BOOL)inSupportFractionalSeconds;

// Convenience String Formatting Methods
- (NSString *)BCC_timeIntervalSince1970String;
- (NSString *)BCC_timeString;
- (NSString *)BCC_monthNameString;
- (NSString *)BCC_dayOfWeekString;
- (NSString *)BCC_veryShortDateString;
- (NSString *)BCC_shortDateString;
- (NSString *)BCC_longDateString;
- (NSString *)BCC_veryLongDateString;
- (NSString *)BCC_SMSStyleDateString;
- (NSString *)BCC_relativeDateString;
- (NSString *)BCC_relativeDateStringWithCutoff:(NSTimeInterval)cutoff fullDateFormatter:(NSDateFormatter *)fullDateFormatter nowText:(NSString *)nowText useAbbreviatedUnits:(BOOL)abbreviatedUnits;

// HTTP Dates
- (NSString *)BCC_HTTPTimeZoneHeaderString;
- (NSString *)BCC_HTTPTimeZoneHeaderStringForTimeZone:(NSTimeZone *)inTimeZone;
- (NSString *)BCC_ISO8601String;
- (NSString *)BCC_ISO8601StringForLocalTimeZone;
- (NSString *)BCC_ISO8601StringForTimeZone:(NSTimeZone *)inTimeZone;
- (NSString *)BCC_ISO8601StringForTimeZone:(NSTimeZone *)inTimeZone usingFractionalSeconds:(BOOL)inUseFractionalSeconds;

@end
