//
//  NSDictionary+BCCAdditions.h
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (BCCAdditions)

// URL Parameter Strings
+ (NSDictionary *)BCC_dictionaryWithURLEncodedString:(NSString *)urlEncodedString;
- (NSString *)BCC_URLEncodedStringValue;
- (NSString *)BCC_URLEncodedQuotedKeyValueListValue;

// Sorting
- (NSArray *)BCC_sortedKeys;
- (NSArray *)BCC_sortedArrayUsingKeyValues;

// Convenience Accessors
- (id)BCC_safeObjectForKey:(id)key;
- (id)BCC_safeObjectForKey:(id)key withClass:(Class)classType;
- (NSDictionary *)BCC_dictionaryForKey:(id)key;
- (NSArray *)BCC_arrayForKey:(id)key;
- (NSString *)BCC_stringForKey:(id)key;
- (NSNumber *)BCC_numberForKey:(id)key;
- (NSData *)BCC_dataForKey:(id)key;
- (NSDate *)BCC_dateForKey:(id)key;
- (NSURL *)BCC_URLForKey:(id)key;
- (BOOL)BCC_boolForKey:(id)key;
- (float)BCC_floatForKey:(id)key;
- (double)BCC_doubleForKey:(id)key;
- (NSUInteger)BCC_unsignedIntegerForKey:(id)key;
- (NSInteger)BCC_integerForKey:(id)key;

@end


@interface NSMutableDictionary (CCAdditions)

- (void)BCC_addUniqueEntriesFromDictionary:(NSDictionary *)inDictionary;

@end