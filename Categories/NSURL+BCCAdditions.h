//
//  NSURL+STAdditions.h
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2013 Brooklyn Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (BCCAdditions)

- (NSString *)BCC_absoluteStringMinusScheme;
- (NSString *)BCC_pathIncludingQueryString;
- (NSString *)BCC_absoluteStringMinusQueryString;
- (NSDictionary *)BCC_queryParameters;
- (NSURL *)BCC_URLByAppendingString:(NSString *)string;
- (NSURL *)BCC_URLByAppendingQueryParameters:(NSDictionary *)parameters;

@end
