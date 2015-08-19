//
//  NSNumber+BCCAdditions.h
//  Niche
//
//  Created by Buzz Andersen on 1/16/15.
//  Copyright (c) 2015 Niche. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (BCCAdditions)

- (NSString *)BCC_abbreviatedString;
- (NSDate *)BCC_dateWithTimeIntervalSince1970Value;

@end
