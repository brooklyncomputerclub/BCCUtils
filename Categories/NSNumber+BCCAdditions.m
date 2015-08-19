//
//  NSNumber+BCCAdditions.m
//  Niche
//
//  Created by Buzz Andersen on 1/16/15.
//  Copyright (c) 2015 Niche. All rights reserved.
//

#import "NSNumber+BCCAdditions.h"


@implementation NSNumber (BCCAdditions)

- (NSString *)BCC_abbreviatedString
{
    NSNumber *millions = @(1000000);
    NSNumber *thousands = @(1000);
    
    NSString *stringValue = nil;
    if ([self compare:millions] == NSOrderedDescending || [self compare:millions] == NSOrderedSame) {
        // Millions
        NSUInteger value = [self unsignedIntegerValue];
        NSUInteger truncatedValue = value / 1000000;
        if (truncatedValue == 0) {
            stringValue = @"1M";
        } else {
            stringValue = [NSString stringWithFormat:@"%luM", (unsigned long)truncatedValue];
        }
    } else if (([self compare:thousands] == NSOrderedDescending || [self compare:thousands] == NSOrderedSame)) {
        // Thousands
        NSUInteger value = [self unsignedIntegerValue];
        NSUInteger truncatedValue = value / 1000;
        if (truncatedValue == 0) {
            stringValue = @"1K";
        } else {
            stringValue = [NSString stringWithFormat:@"%luK", (unsigned long)truncatedValue];
        }
    } else {
        stringValue = [self stringValue];
    }
    
    return stringValue;
}

- (NSDate *)BCC_dateWithTimeIntervalSince1970Value
{
    NSTimeInterval interval = [self floatValue];
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

@end
