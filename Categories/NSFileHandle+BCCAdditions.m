//
//  NSFileHandle+BCCAdditions.m
//
//  Created by Buzz Andersen on 7/16/12.
//  Copyright (c) 2013 Brooklyn Computer Club. All rights reserved.
//

#import "NSFileHandle+BCCAdditions.h"


@implementation NSFileHandle (BCCAdditions)

- (void)BCC_writeUTF8StringWithFormat:(NSString *)inString, ...
{
    va_list args;
    va_start(args, inString);
    
    [self BCC_writeUTF8StringWithFormat:inString arguments:args];
	
    va_end(args);
}

- (void)BCC_writeUTF8StringWithFormat:(NSString *)inString arguments:(va_list)inArguments
{
    NSString *formattedString = [[NSString alloc] initWithFormat:inString arguments:inArguments];
    [self BCC_writeUTF8String:formattedString];
}

- (void)BCC_writeUTF8String:(NSString *)inString;
{
    [self BCC_writeString:inString withEncoding:NSUTF8StringEncoding];
}

- (void)BCC_writeString:(NSString *)inString withEncoding:(NSStringEncoding)inEncoding
{
    NSUInteger byteLength = [inString lengthOfBytesUsingEncoding:inEncoding];
    
    if (!byteLength) {
        return;
    }
    
    char *buffer = malloc(byteLength);
    
    NSUInteger usedLength = 0;
    if ([inString getBytes:buffer maxLength:byteLength usedLength:&usedLength encoding:inEncoding options:NSStringEncodingConversionExternalRepresentation range:NSMakeRange(0,byteLength) remainingRange:NULL]) {
        NSData *stringData = [[NSData alloc] initWithBytes:buffer length:usedLength];
        [self writeData:stringData];
    }
    
    free(buffer);
}

@end
