//
//  NSManagedObject+BCCAdditions.h
//
//  Created by Buzz Andersen on 2/19/11.
//  Copyright 2013 Brooklyn Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NSManagedObject (STAdditions)

// Primitive Accessors
- (BOOL)BCC_boolForKey:(NSString *)key;
- (void)BCC_setBool:(BOOL)value forKey:(NSString *)key;

- (unsigned int)BCC_unsignedIntForKey:(NSString *)key;
- (void)BCC_setUnsignedInt:(unsigned int)value forKey:(NSString *)key;

- (NSUInteger)BCC_unsignedIntegerForKey:(NSString *)key;
- (void)BCC_setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key;

- (double)BCC_doubleForKey:(NSString *)key;
- (void)BCC_setDouble:(double)value forKey:(NSString *)key;

- (NSData *)BCC_dataForKey:(NSString *)inKey;
- (void)BCC_setData:(NSData *)value forKey:(NSString *)key;

#if TARGET_OS_IPHONE
- (CGSize)BCC_sizeForKey:(NSString *)inKey;
- (void)BCC_setSize:(CGSize)value forKey:(NSString *)key;
#endif

@end
