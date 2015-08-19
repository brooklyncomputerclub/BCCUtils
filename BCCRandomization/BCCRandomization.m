//
//  BCCRandomization.m
//
//  Created by Buzz Andersen on 4/12/11.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import "BCCRandomization.h"


BOOL BCCRandomCoinFlip()
{
    return BCCRandomIntegerWithMax(2);
}

NSInteger BCCRandomIntegerWithMax(NSInteger max)
{
    srandomdev();
    
    if (max == 0) {
        return random();
    }
    
    return (random() % max);
}
