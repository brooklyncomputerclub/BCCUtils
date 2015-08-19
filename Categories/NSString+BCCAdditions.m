//
//  NSString+BCCAdditions.m
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import "NSString+BCCAdditions.h"
#import "NSData+BCCAdditions.h"
#import <CommonCrypto/CommonCrypto.h>


@implementation NSString (BCCAdditions)

#pragma mark Whitespace

- (BOOL)BCC_containsWhitespace;
{
    NSRange spaceRange = [self rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (spaceRange.location != NSNotFound);
}

- (NSString *)BCC_stringByTrimmingLeadingAndTrailingWhiteSpace;
{
    return [[self BCC_stringByTrimmingLeadingWhiteSpace] BCC_stringByTrimmingTrailingWhiteSpace];
}

- (NSString *)BCC_stringByTrimmingLeadingWhiteSpace;
{
    if (!self.length) {
        return @"";
    }
    
    NSInteger whiteSpaceIndex = 0;
    
    while (whiteSpaceIndex < self.length && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:whiteSpaceIndex]]) {
        ++whiteSpaceIndex;
    }
    
    return [self substringFromIndex:whiteSpaceIndex];
}

- (NSString *)BCC_stringByTrimmingTrailingWhiteSpace;
{
    if (!self.length) {
        return @"";
    }
    
    NSInteger whiteSpaceIndex = self.length - 1;
    
    while (whiteSpaceIndex >= 0 && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:whiteSpaceIndex]]) {
        --whiteSpaceIndex;
    }
    
    return [self substringToIndex:whiteSpaceIndex + 1];
}

#pragma mark Paths

- (NSString *)BCC_stringByRemovingLastPathComponent;
{
    NSArray *pathComponents = [self pathComponents];
    NSMutableString *returnString = [[NSMutableString alloc] init];
    
    NSString *lastComponent = [pathComponents lastObject];
    for (NSString *currentComponent in pathComponents) {
        if (currentComponent == lastComponent) {
            break;
        }

        [returnString BCC_appendURLPathComponent:currentComponent];
    }
    
    return returnString;
}

#pragma mark URL Escaping

- (NSString *)BCC_stringByEscapingQueryParameters;
{
    // Changed to reflect http://en.wikipedia.org/wiki/Percent-encoding with the addition of the "%"
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]%"), kCFStringEncodingUTF8));
}

- (NSString *)BCC_stringByReplacingPercentEscapes;
{
    NSString *replacedString = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return (NSString*)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)replacedString, CFSTR("")));
}

#pragma mark Templating

- (NSString *)BCC_stringByParsingTagsWithStartDelimeter:(NSString *)inStartDelimiter endDelimeter:(NSString *)inEndDelimiter usingObject:(id)object;
{
    NSScanner *scanner = [NSScanner scannerWithString:self];
    NSMutableString *result = [[NSMutableString alloc] init];
    
    [scanner setCharactersToBeSkipped:nil];
    
    while (![scanner isAtEnd]) {
        NSString *tag;
        NSString *beforeText;
        
        if ([scanner scanUpToString:inStartDelimiter intoString:&beforeText]) {
            [result appendString:beforeText];
        }
        
        if ([scanner scanString:inStartDelimiter intoString:nil]) {
            if ([scanner scanString:inEndDelimiter intoString:nil]) {
                continue;
            } else if ([scanner scanUpToString:inEndDelimiter intoString:&tag] && [scanner scanString:inEndDelimiter intoString:nil]) {
                id keyValue = [object valueForKeyPath:[tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                if (keyValue) {
                    [result appendFormat:@"%@", keyValue];
                } else {
                    [result appendString:@""];
                }
            }
        }
    }
    
    return result;    
}

#pragma mark HTML Entities

- (NSString *)BCC_stringByReplacingHTMLEntities;
{
	NSRange range = NSMakeRange(0, [self length]);
	NSRange subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range];
    
	// if no ampersands, we've got a quick way out
	if (subrange.length == 0) return self;
	NSMutableString *finalString = [NSMutableString stringWithString:self];
	do {
		NSRange semiColonRange = NSMakeRange(subrange.location, NSMaxRange(range) - subrange.location);
		semiColonRange = [self rangeOfString:@";" options:0 range:semiColonRange];
		range = NSMakeRange(0, subrange.location);
		// if we don't find a semicolon in the range, we don't have a sequence
		if (semiColonRange.location == NSNotFound) {
			continue;
		}
		NSRange escapeRange = NSMakeRange(subrange.location, semiColonRange.location - subrange.location + 1);
		NSString *escapeString = [self substringWithRange:escapeRange];
		NSUInteger length = [escapeString length];
		// a squence must be longer than 3 (&lt;) and less than 11 (&thetasym;)
		if (length > 3 && length < 11) {
			if ([escapeString characterAtIndex:1] == '#') {
				unichar char2 = [escapeString characterAtIndex:2];
				if (char2 == 'x' || char2 == 'X') {
					// Hex escape squences &#xa3;
					NSString *hexSequence = [escapeString substringWithRange:NSMakeRange(3, length - 4)];
					NSScanner *scanner = [NSScanner scannerWithString:hexSequence];
					unsigned value;
					if ([scanner scanHexInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 4) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
                    
				} else {
					// Decimal Sequences &#123;
					NSString *numberSequence = [escapeString substringWithRange:NSMakeRange(2, length - 3)];
					NSScanner *scanner = [NSScanner scannerWithString:numberSequence];
					int value;
					if ([scanner scanInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 3) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
				}
			} else {
				// "standard" sequences
                NSString *truncatedString = [escapeString substringWithRange:NSMakeRange(1, length-2)];
                NSString *translatedEntity = [[NSBundle mainBundle] localizedStringForKey:truncatedString value:escapeString table:@"entities"];
                if (translatedEntity) {
                    [finalString replaceCharactersInRange:escapeRange withString:translatedEntity];
                }
			}
		}
	} while ((subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range]).length != 0);
	return finalString;
} 

#pragma mark Encoding

- (NSString *)BCC_stringUsingEncoding:(NSStringEncoding)encoding;
{
    return [[NSString alloc] initWithData:[self dataUsingEncoding:encoding allowLossyConversion:YES] encoding:encoding];
}

#pragma mark Hashes

- (NSString *)BCC_MD5String;
{
	const char *string = [self UTF8String];
	unsigned char md5_result[16];
	CC_MD5(string, (CC_LONG)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], md5_result);
    
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            md5_result[0], md5_result[1], md5_result[2], md5_result[3], 
            md5_result[4], md5_result[5], md5_result[6], md5_result[7],
            md5_result[8], md5_result[9], md5_result[10], md5_result[11],
            md5_result[12], md5_result[13], md5_result[14], md5_result[15]];	
}

- (NSString *)BCC_SHA256String
{
    NSData *SHA256Data = [[self dataUsingEncoding:NSUTF8StringEncoding] BCC_SHA256Value];
    return [SHA256Data BCC_hexString];
}

- (NSString *)BCC_SHA1String
{
    NSData *SHA256Data = [[self dataUsingEncoding:NSUTF8StringEncoding] BCC_SHA1Value];
    return [SHA256Data BCC_hexString];
}

- (NSData *)BCC_hmacSHA1DataValueWithKey:(NSData *)inKey;
{
    NSData *dataValue = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [dataValue BCC_hmacSHA1DataValueWithKey:inKey];
}

#pragma mark Encoding

/*- (NSString *)BCC_base58String;
{
	long long num = strtoll([self UTF8String], NULL, 10);
	
	NSString *alphabet = @"123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ";
	
	NSUInteger baseCount = [alphabet length];
	
	NSString *encoded = @"";
	
	while (num >= baseCount) {
		double div = num / baseCount;
		long long mod = (num - (baseCount * (long long)div));
		NSString *alphabetChar = [alphabet substringWithRange:NSMakeRange(mod, 1)];
		encoded = [NSString stringWithFormat: @"%@%@", alphabetChar, encoded];
		num = (long long)div;
	}
    
	if (num) {
		encoded = [NSString stringWithFormat:@"%@%@", [alphabet substringWithRange:NSMakeRange(num, 1)], encoded];
	}
    
	return encoded;	
}*/

- (NSString *)BCC_base64String;
{
    NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [stringData BCC_base64EncodedString];
}

#pragma mark Obfuscation

-(NSString *)BCC_reverseString
{
    NSMutableString *reversedStr;
    NSUInteger len = [self length];
    
    reversedStr = [NSMutableString stringWithCapacity:len];     
    
    while (len > 0) {
        [reversedStr appendString:
         [NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];
    }
    
    return reversedStr;
}

#pragma mark UUIDs

+ (NSString *)BCC_UUIDString;
{
    return [[NSUUID UUID] UUIDString];
}

#pragma mark Validation

- (BOOL)BCC_isEmailAddress;
{
    // emails can't have whitespace
    if ([self BCC_containsWhitespace]) {
        return NO;
    }
    
    // boot it immediately if it has more than one @ symbol
    // foo @ foo.com
    // foo @ foo @ foo . com
    if ([self componentsSeparatedByString:@"@"].count > 2) {
        return NO;
    }
    
    NSString *emailRegex = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$";
    return [self rangeOfString:emailRegex options:NSRegularExpressionSearch].location != NSNotFound;
}

#pragma mark Phone Numbers

- (NSString *)BCC_normalizedUSPhoneNumberString
{
    NSRegularExpression *phoneNormalizeExpression = [NSRegularExpression regularExpressionWithPattern:@"[^0-9A-Za-z_]" options:NSRegularExpressionCaseInsensitive error:NULL];

    NSMutableString *mutableCopy = [self mutableCopy];
    
    [phoneNormalizeExpression replaceMatchesInString:mutableCopy options:0 range:NSMakeRange(0, self.length) withTemplate:@""];
    
    if (mutableCopy.length == 10) {
        [mutableCopy insertString:@"1" atIndex:0];
    }
    
    if (mutableCopy.length < 11 || [mutableCopy characterAtIndex:0] != '1') {
        return nil;
    } 
    
    return mutableCopy;
}

#pragma mark Dates

- (NSDate *)BCC_dateValueWithMillisecondsSince1970;
{
    return [NSDate dateWithTimeIntervalSince1970:[self doubleValue] / 1000];
}

- (NSDate *)BCC_dateValueWithTimeIntervalSince1970;
{
    return [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
}

// Adapted from Sam Soffes
// http://coding.scribd.com/2011/05/08/how-to-drastically-improve-your-app-with-an-afternoon-and-instruments/

- (NSDate *)BCC_ISO8601DateValue;
{
    if (!self.length) {
        return nil;
    }
    
    struct tm tm;
    time_t t;    
    
    strptime([self cStringUsingEncoding:NSUTF8StringEncoding], "%Y-%m-%dT%H:%M:%S%z", &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);
    
    return [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
}

#pragma mark File Output

/*- (BOOL)BCC_appendLineToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile usingEncoding:(NSStringEncoding)encoding error:(NSError **)error;
{
    if (!self.length) {
        return NO;
    }
    
    NSString *newLineString = self;
    
    if ([self characterAtIndex:[self length] - 1] != '\n') {
        newLineString = [self stringByAppendingString:@"\n"];
    }
    
    return [newLineString appendToFile:path atomically:useAuxiliaryFile usingEncoding:encoding error:error];
}

- (BOOL)BCC_appendToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile usingEncoding:(NSStringEncoding)encoding error:(NSError **)error;
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!fileHandle) {
        return [self writeToFile:path atomically:useAuxiliaryFile encoding:encoding error:error];
    }
    
    [fileHandle truncateFileAtOffset:[fileHandle seekToEndOfFile]];
    NSData *encodedData = [self dataUsingEncoding:encoding];
    
    if (!encodedData) {
        return NO;
    }
    
    [fileHandle writeData:encodedData];
    return YES;
}*/

#pragma mark Drawing

#if TARGET_OS_IPHONE

/*- (CGSize)BCC_drawInRect:(CGRect)inRect withFont:(UIFont *)inFont color:(UIColor *)inColor shadowColor:(UIColor *)inShadowColor shadowOffset:(CGSize)inShadowOffset;
{
    return [self drawInRect:inRect withFont:inFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft color:inColor shadowColor:inShadowColor shadowOffset:inShadowOffset];
}

- (CGSize)BCC_drawInRect:(CGRect)inRect withFont:(UIFont *)inFont lineBreakMode:(UILineBreakMode)inLineBreakMode color:(UIColor *)inColor shadowColor:(UIColor *)inShadowColor shadowOffset:(CGSize)inShadowOffset;
{
    return [self drawInRect:inRect withFont:inFont lineBreakMode:inLineBreakMode alignment:UITextAlignmentLeft color:inColor shadowColor:inShadowColor shadowOffset:inShadowOffset];
}

- (CGSize)BCC_drawInRect:(CGRect)inRect withFont:(UIFont *)inFont lineBreakMode:(UILineBreakMode)inLineBreakMode alignment:(UITextAlignment)alignment color:(UIColor *)inColor shadowColor:(UIColor *)inShadowColor shadowOffset:(CGSize)inShadowOffset;
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, inShadowOffset, 0.0, inShadowColor.CGColor);
    CGContextSetFillColorWithColor(context, inColor.CGColor);
    CGSize renderedSize = [self drawInRect:inRect withFont:inFont lineBreakMode:inLineBreakMode];   
    CGContextRestoreGState(context);

    return renderedSize;
}*/

#endif

@end


@implementation NSMutableString (BCCAdditions)

#pragma mark Predicates

- (void)BCC_appendPredicateCondition:(NSString *)inPredicateConditionString;
{
    [self BCC_appendPredicateConditionWithOperator:@"AND" string:inPredicateConditionString];
}

- (void)BCC_appendPredicateConditionWithOperator:(NSString *)inOperator string:(NSString *)inPredicateConditionString;
{
    if (self.length) {
        [self appendFormat:@" %@ ", inOperator];
    }
    
    [self appendString:inPredicateConditionString];
}

- (void)BCC_appendPredicateConditionWithFormat:(NSString *)inPredicateConditionString, ...;
{
    va_list args;
    va_start(args, inPredicateConditionString);
    
    [self BCC_appendPredicateConditionWithOperator:@"AND" format:inPredicateConditionString arguments:args];
	
    va_end(args);
}

- (void)BCC_appendPredicateConditionWithOperator:(NSString *)inOperator format:(NSString *)inPredicateConditionString, ...;
{
    va_list args;
    va_start(args, inPredicateConditionString);
    
    [self BCC_appendPredicateConditionWithOperator:inOperator format:inPredicateConditionString arguments:args];
	
    va_end(args);
}

- (void)BCC_appendPredicateConditionWithOperator:(NSString *)inOperator format:(NSString *)inPredicateConditionString arguments:(va_list)inArguments;
{
    NSString *formattedString = [[NSString alloc] initWithFormat:inPredicateConditionString arguments:inArguments];
    [self BCC_appendPredicateConditionWithOperator:inOperator string:formattedString];
}

#pragma mark Paths

- (void)BCC_appendURLPathComponent:(NSString *)inPathComponent;
{
    [self BCC_appendURLPathComponent:inPathComponent queryString:nil];
}

- (void)BCC_appendURLPathComponent:(NSString *)inPathComponent queryString:(NSString *)inQueryString;
{
    if (!inPathComponent.length) {
        return;
    }
    
    if ([inPathComponent isEqualToString:@"/"]) {
        [self appendString:inPathComponent];
        return;
    }
    
    // See if there is already a query string
    NSRange queryRange = [self rangeOfString:@"\?.*" options:NSRegularExpressionSearch];
    if (queryRange.location != NSNotFound) {
        // Remove the existing query string, but cache it
        NSString *foundQueryString = [self substringWithRange:queryRange];
        [self deleteCharactersInRange:queryRange];
        
        // If the user passed in a new query string, or we
        // have a query string with only a ?, simply lose
        // the existing query string. Otherwise, append it
        // after the
        if (foundQueryString.length > 1 && !inQueryString.length) {
            [self BCC_appendURLPathComponent:inPathComponent queryString:foundQueryString];
            return;
        }
    }
    
    if (!self.length || [self hasSuffix:@"/"]) {
        [self appendString:inPathComponent];
    } else {
        [self appendFormat:@"/%@", inPathComponent];
    }
    
    if (inQueryString.length) {
        [self appendString:inQueryString];
    }
}

- (void)BCC_appendURLPathComponents:(NSArray *)inPathComponents;
{
    for (NSString *currentPathComponent in inPathComponents) {
        [self BCC_appendURLPathComponent:currentPathComponent];
    }
}

- (void)BCC_appendURLQueryValue:(id)value forKey:(NSString *)key
{
    // TO DO
}

@end

