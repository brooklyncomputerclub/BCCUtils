//
//  NSFileHandle+STAdditions.h
//
//  Created by Buzz Andersen on 7/16/12.
//  Copyright (c) 2013 Brooklyn Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileHandle (BCCAdditions)

- (void)BCC_writeUTF8String:(NSString *)inString;
- (void)BCC_writeUTF8StringWithFormat:(NSString *)inString, ...;
- (void)BCC_writeUTF8StringWithFormat:(NSString *)inString arguments:(va_list)inArguments;
- (void)BCC_writeString:(NSString *)inString withEncoding:(NSStringEncoding)inEncoding;

@end
