//
//  BCCTargetActionQueue.m
//
//  Created by Buzz Andersen on 6/28/12.
//  Copyright (c) 2013 Brooklyn Computer Club. All rights reserved.
//

#import "BCCTargetActionQueue.h"


@interface BCCTargetActionQueue ()

@property (strong, nonatomic) NSMutableDictionary *targetActionInfo;
@property (strong, nonatomic) dispatch_queue_t queue;

- (void)_removeTarget:(id)inTarget forKey:(NSString *)inKey;

@end


@implementation BCCTargetActionQueue

#pragma mark - Initialization

- (id)initWithIdentifier:(NSString *)identifier
{
    if (!(self = [super init])) {
        return nil;
    }

    _identifier = identifier;
    
    self.queue = dispatch_queue_create("com.brooklyncomputerclub.BCCTargetActionQueue", DISPATCH_QUEUE_SERIAL);
    //dispatch_set_target_queue(_queue, dispatch_get_main_queue());
    
    return self;
}

- (void)dealloc;
{
    dispatch_sync(self.queue, ^{ });
    _queue = NULL;
}

#pragma mkar - NSObject

- (NSString *)description
{
    NSMutableString *description = [[NSMutableString alloc] initWithFormat:@"<%@: %p (identifier: %@)> Target Actions:\n", NSStringFromClass([self class]), self, self.identifier];
    
    for (NSString *currentTargetActionKey in [self.targetActionInfo allKeys]) {
        NSArray *currentTargetActions = [self.targetActionInfo objectForKey:currentTargetActionKey];
        [description appendFormat:@"%@: %@", currentTargetActionKey, currentTargetActions];
    }
    
    return description;
}

#pragma mark - Enumeration

- (void)enumerateTargetActionsForKey:(NSString *)inKey usingBlock:(BCCTargetActionEnumerationBlock)inEnumerationBlock
{
    if (!inKey || !inEnumerationBlock) {
        return;
    }

    NSArray *targetActionsForKey = [[self targetActionsForKey:inKey] copy];
    if (targetActionsForKey.count < 1) {
        return;
    }
    
    for (BCCTargetAction *currentTargetAction in targetActionsForKey) {
        if (!currentTargetAction.target) {
            continue;
        }
        
        inEnumerationBlock(currentTargetAction);
    }
}

#pragma mark - Accessors

- (NSDictionary *)targetActionInfo;
{
    if (_targetActionInfo == NULL) {
        _targetActionInfo = [[NSMutableDictionary alloc] init];
    }
    
    return _targetActionInfo;
}

- (NSEnumerator *)keyEnumerator;
{
    return [self.targetActionInfo keyEnumerator];
}

- (NSArray *)targetActionsForKey:(NSString *)inKey
{
    if (!inKey) {
        return nil;
    }
    
    return [self.targetActionInfo objectForKey:inKey];
}

- (NSArray *)targetActionsForTarget:(id)inTarget
{
    return [self targetActionsForTarget:inTarget key:nil];
}

- (NSArray *)targetActionsForTarget:(id)inTarget key:(NSString *)inKey
{
    if (!inTarget) {
        return nil;
    }

    NSMutableArray *matchingTargetActions = [[NSMutableArray alloc] init];

    NSEnumerator *targetActionListEnumerator = [self.targetActionInfo objectEnumerator];
    for (NSArray *currentTargetActionList in targetActionListEnumerator) {
        for (BCCTargetAction *currentTargetAction in currentTargetActionList) {
            if (currentTargetAction.target == inTarget && (!inKey || [inKey isEqualToString:currentTargetAction.key])) {
                [matchingTargetActions addObject:currentTargetAction];
            }
        }
    }
    
    return matchingTargetActions;
}

#pragma mark - Target/Action Methods

- (BCCTargetAction *)addTarget:(id)inTarget action:(SEL)inAction forKey:(NSString *)inKey;
{
    if (!inTarget || !inKey.length || !inAction) {
        return nil;
    }
    
    BCCTargetAction *targetAction = [BCCTargetAction targetActionForKey:inKey withTarget:inTarget action:inAction];
    [self addTargetAction:targetAction];
    
    return targetAction;
}

- (BCCTargetAction *)addTarget:(id)inTarget actionBlock:(void(^)())inActionBlock forKey:(NSString *)inKey;
{
    if (!inTarget || !inKey.length || !inActionBlock) {
        return nil;
    }
    
    BCCTargetAction *targetAction = [BCCTargetAction targetActionForKey:inKey withActionBlock:inActionBlock];
    [self addTargetAction:targetAction];
    
    return targetAction;
}
 
- (void)addTargetAction:(BCCTargetAction *)inTargetAction;
{
    if (!inTargetAction) {
        return;
    }
    
    dispatch_async(self.queue, ^{
        NSMutableArray *keyTargetActionsArray = (NSMutableArray *)[self targetActionsForKey:inTargetAction.key];
        if (!keyTargetActionsArray) {
            // If we don't already have an array of target/actions for this
            // key, create one and add it to the mapping.
            keyTargetActionsArray = [[NSMutableArray alloc] init];
            [keyTargetActionsArray addObject:inTargetAction];
            [self.targetActionInfo setObject:keyTargetActionsArray forKey:inTargetAction.key];
            return;
        }
        
        [keyTargetActionsArray addObject:inTargetAction];
    });
}

- (void)removeTarget:(id)inTarget;
{
    // Iterate through all the keys and remove this target
    // from each as appropriate
    __block id safeTarget = inTarget;
    dispatch_sync(self.queue, ^{
        NSEnumerator *keyEnumerator = [self.targetActionInfo keyEnumerator];
        for (NSString *currentKey in keyEnumerator) {
            [self _removeTarget:safeTarget forKey:currentKey];
        }
    });
}

- (void)removeTarget:(id)inTarget forKey:(NSString *)inKey;
{
    __block id safeTarget = inTarget;
    dispatch_sync(self.queue, ^{
        [self _removeTarget:safeTarget forKey:inKey];
    });
}

- (void)_removeTarget:(id)inTarget forKey:(NSString *)inKey;
{
    NSMutableArray *objectsToRemove = [[NSMutableArray alloc] init];
    
    NSMutableArray *keyTargetActionsArray = (NSMutableArray *)[self targetActionsForKey:inKey];
    for (BCCTargetAction *currentTargetAction in keyTargetActionsArray) {
        if (currentTargetAction.target &&  currentTargetAction.target != inTarget) {
            continue;
        }
        
        // If the target is present for this key, remove it
        currentTargetAction.target = nil;
        [objectsToRemove addObject:currentTargetAction];
    }
    
    [keyTargetActionsArray removeObjectsInArray:objectsToRemove];
}

- (void)performAction:(BCCTargetAction *)inTargetAction withObject:(id)inObject;
{
    if (!inTargetAction.target) {
        return;
    }
    
    if (inTargetAction.actionBlock) {
        if (inObject) {
            inTargetAction.actionBlock(inTargetAction.key, inObject);
        } else {
            inTargetAction.actionBlock(inTargetAction.key);
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [inTargetAction.target performSelector:inTargetAction.action withObject:inObject];
#pragma clang diagnostic pop
        });
    }
}

- (void)performActionsForKey:(NSString *)inKey;
{
    [self performActionsForKey:inKey withObject:nil];
}

- (void)performActionsForKey:(NSString *)inKey withObject:(id)inObject;
{
    if (!inKey.length) {
        return;
    }
    
    [self enumerateTargetActionsForKey:inKey usingBlock:^(BCCTargetAction *targetAction) {
        [self performAction:targetAction withObject:inObject];
    }];
}

@end


@implementation BCCTargetAction

#pragma mark - Class Methods

+ (BCCTargetAction *)targetActionForKey:(NSString *)key withTarget:(id)target action:(SEL)action
{
    BCCTargetAction *targetAction = [[[self class] alloc] init];
    targetAction.key = key;
    targetAction.target = target;
    targetAction.action = action;
    
    return targetAction;
}

+ (BCCTargetAction *)targetActionForKey:(NSString *)key withActionBlock:(void(^)())actionBlock
{
    BCCTargetAction *targetAction = [[[self class] alloc] init];
    targetAction.key = key;
    targetAction.actionBlock = actionBlock;
    
    return targetAction;
}

#pragma mark - Initialization

- (void)dealloc
{
    _target = nil;
    _action = NULL;    
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p (key: %@; target: %@)>", NSStringFromClass([self class]), self, self.key, self.target];
}

@end
