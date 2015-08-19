//
//  NSManagedObject+BCCAdditions.m
//
//  Created by Buzz Andersen on 2/19/11.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import "NSManagedObject+BCCAdditions.h"


@implementation NSManagedObject (STAdditions)

#pragma mark Primitive Accessors

- (BOOL)BCC_boolForKey:(NSString *)key;
{
    [self willAccessValueForKey:key];
    NSNumber *value = [self primitiveValueForKey:key];
    [self didAccessValueForKey:key];
    
    return [value boolValue];
}

- (void)BCC_setBool:(BOOL)value forKey:(NSString *)key;
{
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:[NSNumber numberWithBool:value] forKey:key];
    [self didChangeValueForKey:key];
}

- (unsigned int)BCC_unsignedIntForKey:(NSString *)key;
{
    [self willAccessValueForKey:key];
    NSNumber *value = [self primitiveValueForKey:key];
    [self didAccessValueForKey:key];
    
    return [value unsignedIntValue];
}

- (void)BCC_setUnsignedInt:(unsigned int)value forKey:(NSString *)key;
{
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:[NSNumber numberWithUnsignedInt:value] forKey:key];
    [self didChangeValueForKey:key];
}

- (NSUInteger)BCC_unsignedIntegerForKey:(NSString *)key;
{
    [self willAccessValueForKey:key];
    NSNumber *value = [self primitiveValueForKey:key];
    [self didAccessValueForKey:key];
    
    return [value unsignedIntegerValue];
}

- (void)BCC_setUnsignedInteger:(NSUInteger)value forKey:(NSString *)key;
{
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:[NSNumber numberWithUnsignedInteger:value] forKey:key];
    [self didChangeValueForKey:key];
}

- (double)BCC_doubleForKey:(NSString *)key;
{
    [self willAccessValueForKey:key];
    NSNumber *value = [self primitiveValueForKey:key];
    [self didAccessValueForKey:key];
    
    return [value doubleValue];
}

- (void)BCC_setDouble:(double)value forKey:(NSString *)key;
{
    [self willChangeValueForKey:key];
    [self setPrimitiveValue:[NSNumber numberWithDouble:value] forKey:key];
    [self didChangeValueForKey:key];
}

- (NSData *)BCC_dataForKey:(NSString *)inKey;
{
    [self willAccessValueForKey:inKey];
    NSData *value = [self primitiveValueForKey:inKey];
    [self didAccessValueForKey:inKey];
    
    return value;
}

- (void)BCC_setData:(NSData *)value forKey:(NSString *)key;
{
    [self willAccessValueForKey:key];
    [self setPrimitiveValue:value forKey:key];
    [self didAccessValueForKey:key];
}

#if TARGET_OS_IPHONE

- (CGSize)BCC_sizeForKey:(NSString *)inKey;
{
    [self willAccessValueForKey:inKey];
    NSValue *value = [self primitiveValueForKey:inKey];
    [self didAccessValueForKey:inKey];
    
    return [value CGSizeValue];
}

- (void)BCC_setSize:(CGSize)value forKey:(NSString *)key;
{
    [self willAccessValueForKey:key];
    [self setPrimitiveValue:[NSValue valueWithCGSize:value] forKey:key];
    [self didAccessValueForKey:key];
}

#endif

@end
