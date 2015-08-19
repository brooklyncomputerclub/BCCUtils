//
//  NSArray+BCCAdditions.h
//
//  Created by Buzz Andersen on 2/19/11.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (BCCAdditions)

- (id)BCC_firstObject;
- (id)BCC_objectAtRandomIndex;
- (NSString *)BCC_URLEncodedStringValue;
- (NSString *)BCC_URLEncodedStringValueWithParameterName:(NSString *)parameterName;

@end
