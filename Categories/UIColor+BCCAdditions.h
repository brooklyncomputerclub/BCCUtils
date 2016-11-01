//
//  UIColor+BCCAdditions.h
//
//  Created by Buzz Andersen on 7/7/14.
//  Copyright (c) 2014 Brooklyn Computer Club. All rights reserved.
//


#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

@interface UIColor (BCCAdditions)

+ (UIColor *)BCC_colorFromHexString:(NSString *)hexString;

@end

#endif


