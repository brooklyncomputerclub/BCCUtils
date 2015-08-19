//
//  NSDictionary+BCCAdditions.m
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import "NSDictionary+BCCAdditions.h"
#import "NSArray+BCCAdditions.h"
#import "NSNumber+BCCAdditions.h"
#import "NSDate+BCCAdditions.h"
#import "NSData+BCCAdditions.h"
#import "NSObject+BCCAdditions.h"
#import "NSString+BCCAdditions.h"


@implementation NSDictionary (BCCAdditions)

#pragma mark URL Parameter Strings

+ (NSDictionary *)BCC_dictionaryWithURLEncodedString:(NSString *)urlEncodedString;
{
    NSMutableDictionary *mutableResponseDictionary = [[NSMutableDictionary alloc] init];
    // split string by &s
    NSArray *encodedParameters = [urlEncodedString componentsSeparatedByString:@"&"];
    for (NSString *parameter in encodedParameters) {
        NSArray *keyValuePair = [parameter componentsSeparatedByString:@"="];
        if (keyValuePair.count == 2) {
            NSString *key = [[keyValuePair objectAtIndex:0] BCC_stringByReplacingPercentEscapes];
            NSString *value = [[keyValuePair objectAtIndex:1] BCC_stringByReplacingPercentEscapes];
            [mutableResponseDictionary setObject:value forKey:key];
        }
    }
    return mutableResponseDictionary;
}

- (NSString *)BCC_URLEncodedStringValue;
{
	if (self.count < 1) {
        return @"";
    }
	
	NSEnumerator *keyEnum = [self keyEnumerator];
	NSString *currentKey;
	
	BOOL appendAmpersand = NO;
	
	NSMutableString *parameterString = [[NSMutableString alloc] init];
	
	while ((currentKey = (NSString *)[keyEnum nextObject]) != nil) {
		id currentValue = [self objectForKey:currentKey];
        
        NSString *stringRepresentation = nil;
        
        if ([currentValue respondsToSelector:@selector(BCC_URLEncodedStringValueWithParameterName:)]) {
            stringRepresentation = [currentValue BCC_URLEncodedStringValueWithParameterName:currentKey];
        } else if ([currentValue respondsToSelector:@selector(BCC_URLParameterStringValue)]) {
            NSString *rawStringValue = [currentValue BCC_URLParameterStringValue];
            stringRepresentation = [NSString stringWithFormat:@"%@=%@", currentKey, rawStringValue];
        }
        
        if (stringRepresentation) {
            if (appendAmpersand) {
                [parameterString appendString: @"&"];
            }
            
            [parameterString appendString:stringRepresentation];
        
            appendAmpersand = YES;
        }
	}
	
	return parameterString;
}

- (NSString *)BCC_URLEncodedQuotedKeyValueListValue;
{
	if (self.count < 1) {
        return @"";
    }
	
	NSEnumerator *keyEnum = [self keyEnumerator];
	NSString *currentKey;
	
	BOOL appendComma = NO;
	
	NSMutableString *listString = [[NSMutableString alloc] init];
	
	while ((currentKey = (NSString *)[keyEnum nextObject]) != nil) {
		id currentValue = [self objectForKey:currentKey];
		NSString *stringValue = [currentValue BCC_URLParameterStringValue];
		
		if (stringValue != nil) {
			if (appendComma) {
				[listString appendString: @", "];
			}
			
			NSString *escapedStringValue = [stringValue BCC_stringByEscapingQueryParameters];
			[listString appendFormat: @"%@=\"%@\"", currentKey, escapedStringValue];			
		}
		
		appendComma = YES;
	}
	
	return listString;
}

#pragma mark Sorting

- (NSArray *)BCC_sortedKeys;
{
    return [[self allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSArray *)BCC_sortedArrayUsingKeyValues;
{
	NSArray *sortedKeys = [self BCC_sortedKeys];
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	
	id currentKey;
	
	for (currentKey in sortedKeys) {
		[returnArray addObject:[self objectForKey:currentKey]];
	}
	
	return returnArray;
}

#pragma mark Convenience Accessors

- (id)BCC_safeObjectForKey:(id)key;
{
    id object = [self objectForKey:key];
    
    if (object && [[NSNull null] isEqual:object]) {
        object = nil;
    }
    
    return object;
}

- (id)BCC_safeObjectForKey:(id)key withClass:(Class)classType;
{
    id object = [self BCC_safeObjectForKey:key];
    return [object isKindOfClass:classType] ? object : nil;
}

- (NSDictionary *)BCC_dictionaryForKey:(id)key;
{
    return [self BCC_safeObjectForKey:key withClass:[NSDictionary class]];
}

- (NSArray *)BCC_arrayForKey:(id)key;
{
    return [self BCC_safeObjectForKey:key withClass:[NSArray class]];
}

- (NSString *)BCC_stringForKey:(id)key;
{
    id object = [self BCC_safeObjectForKey:key];
    
    if ([object isKindOfClass:[NSString class]]) {
        return object;
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [object stringValue];
    } else if ([object isKindOfClass:[NSURL class]]) {
        return [object absoluteString];
    } else if ([object isKindOfClass:[NSData class]]) {
        return [object BCC_base64EncodedString];
    } else if ([object isKindOfClass:[NSDate class]]) {
        return [object BCC_ISO8601String];
    }
    
    return nil;
}

- (NSNumber *)BCC_numberForKey:(id)key;
{
    id object = [self BCC_safeObjectForKey:key];
    
    if ([object isKindOfClass:[NSNumber class]]) {
        return object;
    } else if ([object isKindOfClass:[NSString class]]) {
        return [NSDecimalNumber decimalNumberWithString:object];
    }
    
    return nil;
}

- (NSData *)BCC_dataForKey:(id)key;
{
    id object = [self BCC_safeObjectForKey:key];
    
    if ([object isKindOfClass:[NSData class]]) {
        return object;
    } else if ([object isKindOfClass:[NSString class]]) {
        return [object dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (NSDate *)BCC_dateForKey:(id)key;
{
    id object = [self BCC_safeObjectForKey:key];
    
    if ([object isKindOfClass:[NSDate class]]) {
        return object;
    } else if ([object isKindOfClass:[NSString class]]) {
        return [object BCC_ISO8601DateValue];
    } else if ([object isKindOfClass:[NSNumber class]]) {
        return [object BCC_dateWithTimeIntervalSince1970Value];
    }
    
    return nil;
}

- (NSURL *)BCC_URLForKey:(id)key;
{
    id object = [self BCC_safeObjectForKey:key];
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)object;
        
        if (string.length) {
            return [NSURL URLWithString:string];
        }
    } else if ([object isKindOfClass:[NSURL class]]) {
        return object;
    }
    
    return nil;
}

- (BOOL)BCC_boolForKey:(id)key;
{
    id object = [self BCC_safeObjectForKey:key];
    
    if ([object isKindOfClass:[NSNumber class]] || [object isKindOfClass:[NSString class]]) {
        return [object boolValue];
    }
    
    return NO;
}

- (float)BCC_floatForKey:(id)key;
{
    NSNumber *numberValue = [self BCC_numberForKey:key];
    if (!numberValue) {
        return 0.0F;
    }
    
    return [numberValue floatValue];
}

- (double)BCC_doubleForKey:(id)key;
{
    NSNumber *numberValue = [self BCC_numberForKey:key];
    if (!numberValue) {
        return 0.0L;
    }
    
    return [numberValue doubleValue];
}

- (NSUInteger)BCC_unsignedIntegerForKey:(id)key;
{
    NSNumber *numberValue = [self BCC_numberForKey:key];
    if (!numberValue) {
        return 0;
    }
    
    return [numberValue unsignedIntegerValue];
}

- (NSInteger)BCC_integerForKey:(id)key;
{
    NSNumber *numberValue = [self BCC_numberForKey:key];
    if (!numberValue) {
        return 0;
    }
    
    return [numberValue integerValue];
}

@end


@implementation NSMutableDictionary (BCCAdditions)

- (void)BCC_addUniqueEntriesFromDictionary:(NSDictionary *)inDictionary;
{
    NSArray *keys = [inDictionary allKeys];
    
    for (NSString *currentKey in keys) {
        if (![self objectForKey:currentKey]) {
            id object = [inDictionary objectForKey:currentKey];
            [self setObject:object forKey:currentKey];
        }
    }
}

@end