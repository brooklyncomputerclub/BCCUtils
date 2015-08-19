//
//  NSURL+BCCAdditions.m
//
//  Created by Buzz Andersen on 12/29/09.
//  Copyright 2013 Brooklyn Computer Club. All rights reserved.
//

#import "NSURL+BCCAdditions.h"
#import "NSArray+BCCAdditions.h"
#import "NSDictionary+BCCAdditions.h"


@implementation NSURL (BCCAdditions)

- (NSString *)BCC_absoluteStringMinusQueryString;
{
    NSMutableString *returnString = [[NSMutableString alloc] init];
    [returnString appendFormat:@"%@://%@", [self scheme], [self host]];
    
    NSString *thePath = [self path];
    if (thePath) {
        [returnString appendString:thePath];
    }

    return returnString;
}

- (NSString *)BCC_absoluteStringMinusScheme;
{
	return [[self resourceSpecifier] substringFromIndex:2];
}

- (NSString *)BCC_pathIncludingQueryString
{
    if (self.query) {
        return [self.path stringByAppendingFormat:@"?%@", self.query];
    }
    
    return self.path;
}

- (NSDictionary *)BCC_queryParameters;
{
    NSString *query = [self query];
    NSArray *keyValuePairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    for (NSString *pair in keyValuePairs) {
        NSArray *components = [pair componentsSeparatedByString:@"="];
        
        if (components.count == 2) {
            NSString *key = [[components firstObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            if (key && value) {
                [params setObject:value forKey:key];
            }
        }
    }
    
    return params;
}

- (NSURL *)BCC_URLByAppendingString:(NSString *)string;
{
    NSString *baseURL = [self absoluteString];
    
    if ([baseURL hasSuffix:@"/"] && [string hasPrefix:@"/"]) {
        string = [string substringFromIndex:1];
    } else if (string.length && ![baseURL hasSuffix:@"/"] && ![string hasPrefix:@"/"]) {
        // Don't append a trailing / if string is empty.
        string = [@"/" stringByAppendingString:string];
    }
    
    return [NSURL URLWithString:[baseURL stringByAppendingString:string]];
}

- (NSURL *)BCC_URLByAppendingQueryParameters:(NSDictionary *)parameters;
{
    if (!parameters.count) {
        return self;
    }
    
    NSMutableString *urlString = [[self absoluteString] mutableCopy];
    
    if ([self query]) {
        [urlString appendString:@"&"];
    } else {
        [urlString appendString:@"?"];
    }
    
    [urlString appendString:[parameters BCC_URLEncodedStringValue]];
    NSURL *returnURL = [NSURL URLWithString:urlString];
    
    return returnURL;
}

@end
