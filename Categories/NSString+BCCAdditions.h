//
//  NSString+BCCAdditions.h
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (BCCAdditions)

// Whitespace
- (BOOL)BCC_containsWhitespace;
- (NSString *)BCC_stringByTrimmingLeadingAndTrailingWhiteSpace;
- (NSString *)BCC_stringByTrimmingLeadingWhiteSpace;
- (NSString *)BCC_stringByTrimmingTrailingWhiteSpace;

// Paths
- (NSString *)BCC_stringByRemovingLastPathComponent;

// URL Escaping
- (NSString *)BCC_stringByEscapingQueryParameters;
- (NSString *)BCC_stringByReplacingPercentEscapes;

// Templating
- (NSString *)BCC_stringByParsingTagsWithStartDelimeter:(NSString *)inStartDelimiter endDelimeter:(NSString *)inEndDelimiter usingObject:(id)object;

// HTML Entities
- (NSString *)BCC_stringByReplacingHTMLEntities;

// Encoding
- (NSString *)BCC_stringUsingEncoding:(NSStringEncoding)encoding;

// Hashes
- (NSString *)BCC_MD5String;
- (NSString *)BCC_SHA256String;
- (NSString *)BCC_SHA1String;
- (NSData *)BCC_hmacSHA1DataValueWithKey:(NSData *)inKey;

// Encoding
//- (NSString *)BCC_base58String;
- (NSString *)BCC_base64String;

// Obfuscation
- (NSString *)BCC_reverseString;

// UUIDs
+ (NSString *)BCC_UUIDString;

// Validation
- (BOOL)BCC_isEmailAddress;

// Phone Numbers
- (NSString *)BCC_normalizedUSPhoneNumberString;

// Dates
- (NSDate *)BCC_dateValueWithMillisecondsSince1970;
- (NSDate *)BCC_dateValueWithTimeIntervalSince1970;
- (NSDate *)BCC_ISO8601DateValue;

// File Output
/*- (BOOL)BCC_appendToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile usingEncoding:(NSStringEncoding)encoding error:(NSError **)error;
- (BOOL)BCC_appendLineToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile usingEncoding:(NSStringEncoding)encoding error:(NSError **)error;*/

// Drawing
#if TARGET_OS_IPHONE
/*- (CGSize)BCC_drawInRect:(CGRect)inRect withFont:(UIFont *)inFont color:(UIColor *)inColor shadowColor:(UIColor *)inShadowColor shadowOffset:(CGSize)inShadowOffset;
- (CGSize)BCC_drawInRect:(CGRect)inRect withFont:(UIFont *)inFont lineBreakMode:(UILineBreakMode)inLineBreakMode color:(UIColor *)inColor shadowColor:(UIColor *)inShadowColor shadowOffset:(CGSize)inShadowOffset;
- (CGSize)BCC_drawInRect:(CGRect)inRect withFont:(UIFont *)inFont lineBreakMode:(UILineBreakMode)inLineBreakMode alignment:(UITextAlignment)alignment color:(UIColor *)inColor shadowColor:(UIColor *)inShadowColor shadowOffset:(CGSize)inShadowOffset;*/
#endif

@end


@interface NSMutableString (BCCAdditions)

// Predicates
- (void)BCC_appendPredicateCondition:(NSString *)predicateCondition;
- (void)BCC_appendPredicateConditionWithOperator:(NSString *)inOperator string:(NSString *)inPredicateConditionString;

- (void)BCC_appendPredicateConditionWithFormat:(NSString *)inPredicateConditionString, ...;
- (void)BCC_appendPredicateConditionWithOperator:(NSString *)inOperator format:(NSString *)inPredicateCondition, ...;
- (void)BCC_appendPredicateConditionWithOperator:(NSString *)inOperator format:(NSString *)inPredicateCondition arguments:(va_list)inArguments;

// Paths
- (void)BCC_appendURLPathComponent:(NSString *)inPathComponent;
- (void)BCC_appendURLPathComponent:(NSString *)inPathComponent queryString:(NSString *)inQueryString;
- (void)BCC_appendURLPathComponents:(NSArray *)inPathComponents;

// Query Strings
- (void)BCC_appendURLQueryValue:(id)value forKey:(NSString *)key;

@end
