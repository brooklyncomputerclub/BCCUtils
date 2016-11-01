//
//  UIColor+BCCAdditions.m
//
//  Created by Buzz Andersen on 7/7/14.
//  Copyright (c) 2014 Brooklyn Computer Club. All rights reserved.
//

#import "UIColor+BCCAdditions.h"

#if TARGET_OS_IPHONE

@implementation UIColor (BCCAdditions)

+ (UIColor *)BCC_colorFromHexString:(NSString *)hexString
{
    if (!hexString) {
        return nil;
    }
    
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end

#endif
