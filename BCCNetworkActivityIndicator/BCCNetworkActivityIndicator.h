//
//  BCCNetworkActivityIndicator.h
//
//  Created by Buzz Andersen on 3/16/11.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BCCNetworkActivityIndicator : NSObject {
    NSInteger count;
}

+ (BCCNetworkActivityIndicator *)sharedIndicator;
- (void)increment;
- (void)decrement;

@end
