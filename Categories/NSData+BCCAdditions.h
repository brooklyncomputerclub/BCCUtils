//
//  NSData+BCCAdditions.h
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.

#import <Foundation/Foundation.h>


@interface NSData (BCCAdditions)

// SHA
- (NSData *)BCC_hmacSHA1DataValueWithKey:(NSData *)keyData;
- (NSData *)BCC_SHA1Value;
- (NSData *)BCC_SHA256Value;

// Hex Strings
- (NSString *)BCC_hexString;

// UTF8
- (NSString *)BCC_UTF8String;

@end


@interface NSMutableData (BCCAdditions)

- (void)BCC_appendUTF8String:(NSString *)inString;
- (void)BCC_appendUTF8StringWithFormat:(NSString *)inString, ...;
- (void)BCC_appendUTF8StringWithFormat:(NSString *)inString arguments:(va_list)inArguments;
- (void)BCC_appendString:(NSString *)inString withEncoding:(NSStringEncoding)inEncoding;

@end


void *BCCNewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength);

char *BCCNewBase64Encode(
                      const void *inputBuffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength);

@interface NSData (Base64)

+ (NSData *)BCC_dataFromBase64String:(NSString *)aString;
- (NSString *)BCC_base64EncodedString;

@end