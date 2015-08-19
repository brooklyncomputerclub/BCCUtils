//
//  NSArray+BCCAdditions.m
//
//  Created by Buzz Andersen on 2/19/11.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import "BCCRandomization.h"
#import "NSArray+BCCAdditions.h"
#import "NSObject+BCCAdditions.h"
#import "NSString+BCCAdditions.h"


@implementation NSArray (BCCAdditions)

- (id)BCC_firstObject
{
    return self.count > 0 ? [self objectAtIndex:0] : nil;
}

- (id)BCC_objectAtRandomIndex
{
    if (!self.count) {
        return nil;
    }
    
    if (self.count < 2) {
        return [self objectAtIndex:0];
    }
    
    return [self objectAtIndex:BCCRandomIntegerWithMax(self.count)];
}

- (NSString *)BCC_URLEncodedStringValue
{
	if (self.count < 1) {
        return @"";
    }
        
	BOOL appendAmpersand = NO;
    
	NSMutableString *parameterString = [[NSMutableString alloc] init];
    
	for (id currentValue in self) {
		NSString *stringValue = [currentValue BCC_URLParameterStringValue];
        
		if (stringValue != nil) {
			if (appendAmpersand) {
				[parameterString appendString:@"&"];
			}
            
			NSString *escapedStringValue = [stringValue BCC_stringByEscapingQueryParameters];
            
			[parameterString appendFormat:@"%@", escapedStringValue];
		}
        
		appendAmpersand = YES;
	}
    
	return parameterString;
}

- (NSString *)BCC_URLEncodedStringValueWithParameterName:(NSString *)parameterName
{
    if (self.count < 1 || !parameterName) {
        return @"";
    }
    
    BOOL appendAmpersand = NO;
    
    NSMutableString *parameterString = [[NSMutableString alloc] init];
    
    for (id currentValue in self) {
        NSString *stringValue = [currentValue BCC_URLParameterStringValue];
        
        if (stringValue != nil) {
            if (appendAmpersand) {
                [parameterString appendString:@"&"];
            }
            
            NSString *escapedStringValue = [stringValue BCC_stringByEscapingQueryParameters];
            
            [parameterString appendFormat:@"%@[]=%@", parameterName, escapedStringValue];
        }
        
        appendAmpersand = YES;
    }
    
    return parameterString;
}

@end
