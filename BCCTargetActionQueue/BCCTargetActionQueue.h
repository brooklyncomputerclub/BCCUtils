//
//  BCCTargetActionQueue.h
//
//  Created by Buzz Andersen on 6/28/12.
//  Copyright (c) 2013 Brooklyn Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCCTargetAction;


typedef void (^BCCTargetActionEnumerationBlock)(BCCTargetAction *targetAction);


@interface BCCTargetActionQueue : NSObject

@property (strong, nonatomic) NSString *identifier;

- (id)initWithIdentifier:(NSString *)identifier;

- (void)enumerateTargetActionsForKey:(NSString *)inKey usingBlock:(BCCTargetActionEnumerationBlock)enumerationBlock;

- (NSEnumerator *)keyEnumerator;

- (NSArray *)targetActionsForTarget:(id)inTarget;
- (NSArray *)targetActionsForKey:(NSString *)inKey;
- (NSArray *)targetActionsForTarget:(id)inTarget key:(NSString *)inKey;

- (BCCTargetAction *)addTarget:(id)inTarget action:(SEL)inAction forKey:(NSString *)inKey;
- (BCCTargetAction *)addTarget:(id)inTarget actionBlock:(void(^)())inActionBlock forKey:(NSString *)inKey;
- (void)addTargetAction:(BCCTargetAction *)inTargetAction;

- (void)removeTarget:(id)inTarget;
- (void)removeTarget:(id)inTarget forKey:(NSString *)inKey;

- (void)performAction:(BCCTargetAction *)inTargetAction withObject:(id)inObject;
- (void)performActionsForKey:(NSString *)inKey;
- (void)performActionsForKey:(NSString *)inKey withObject:(id)inObject;

@end


@interface BCCTargetAction : NSObject

@property (strong, nonatomic) NSString *key;
@property (unsafe_unretained, nonatomic) id target;
@property (unsafe_unretained, nonatomic) SEL action;
@property (copy, nonatomic) void(^actionBlock)();

+ (BCCTargetAction *)targetActionForKey:(NSString *)key withTarget:(id)target action:(SEL)action;
+ (BCCTargetAction *)targetActionForKey:(NSString *)key withActionBlock:(void(^)())actionBlock;

@end
