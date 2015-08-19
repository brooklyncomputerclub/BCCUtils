//
//  NSObject+BCCAdditions.m
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import "NSObject+BCCAdditions.h"
#import "NSArray+BCCAdditions.h"
#import "NSDate+BCCAdditions.h"
#import "NSDictionary+BCCAdditions.h"
#import "NSString+BCCAdditions.h"


@implementation NSObject (BCCAdditions)

#pragma mark URL Parameter Strings

- (NSString *)BCC_URLParameterStringValue
{
	NSString *stringValue = nil;
	
	if ([self isKindOfClass:[NSString class]]) {
		stringValue = [(NSString *)self BCC_stringByEscapingQueryParameters];
	} else if ([self isKindOfClass:[NSNumber class]]) {
		stringValue = [[(NSNumber *)self stringValue] BCC_stringByEscapingQueryParameters];
	} else if ([self isKindOfClass:[NSDate class]]) {
        stringValue = [[(NSDate *)self BCC_HTTPTimeZoneHeaderString] BCC_stringByEscapingQueryParameters];
	} else if ([self isKindOfClass:[NSDictionary class]]) {
        stringValue = [(NSDictionary *)self BCC_URLEncodedStringValue];
    } else if ([self isKindOfClass:[NSArray class]]) {
        stringValue = [(NSArray *)self BCC_URLEncodedStringValue];
    }
    
	return stringValue;
}

@end
