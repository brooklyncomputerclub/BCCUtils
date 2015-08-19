//
//  NSFileManager+BCCAdditions.m
//
//  Created by Buzz Andersen on 2/19/11.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import "NSFileManager+BCCAdditions.h"
#import "NSArray+BCCAdditions.h"
#import "NSDate+BCCAdditions.h"
#import "NSString+BCCAdditions.h"
#include <sys/stat.h>


@implementation NSFileManager (BCCAdditions)

- (NSString *)BCC_applicationSupportPath;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *rootDirectory = [paths firstObject];
    
    if (!rootDirectory.length) {
        return nil;
    }

    return rootDirectory;
}

- (NSString *)BCC_applicationSupportPathIncludingAppName;
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    return [self BCC_applicationSupportFileName:appName];
}

- (NSString *)BCC_applicationSupportFileName:(NSString *)inFileName;
{
    NSString *appSupportPath = [self BCC_applicationSupportPath];
    if (!appSupportPath.length) {
        return nil;
    }
    
    if (!inFileName.length) {
        return appSupportPath;
    }
    
    return [appSupportPath stringByAppendingPathComponent:inFileName];
}

- (NSString *)BCC_cachePath;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *rootDirectory = [paths firstObject];
    
    if (!rootDirectory) {
        return nil;
    }
    
    return rootDirectory;
}

- (NSString *)BCC_cachePathIncludingAppName;
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    return [self BCC_cacheFileName:appName];
}

- (NSString *)BCC_cacheFileName:(NSString *)inFileName;
{
    NSString *cachePath = [self BCC_cachePath];
    if (!cachePath.length) {
        return nil;
    }

    if (!inFileName) {
        return cachePath;
    }
    
    return [cachePath stringByAppendingPathComponent:inFileName];
}

- (BOOL)BCC_recursivelyCreatePath:(NSString *)inPath;
{
    return [self BCC_recursivelyCreatePath:inPath lastComponentIsFile:NO];
}

- (BOOL)BCC_recursivelyCreatePath:(NSString *)inPath lastComponentIsFile:(BOOL)isFile;
{
    if ([self fileExistsAtPath:inPath isDirectory:NULL]) {
        return NO;
    }
    
    NSArray *pathComponents = [inPath pathComponents];
    if (!pathComponents.count || (isFile && pathComponents.count < 2)) {
        return NO;
    }
    
    NSString *actualPath = isFile ? [inPath BCC_stringByRemovingLastPathComponent] : inPath;
    NSError *error = nil;
    BOOL directoryCreated = [self createDirectoryAtPath:actualPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"Unable to recursively create path due to error: %@", error);
    }
    
    if (!isFile || !directoryCreated) {
        return directoryCreated;
    }
    
    return [[NSFileManager defaultManager] createFileAtPath:inPath contents:nil attributes:nil];
}

- (unsigned long long)BCC_fileSizeAtPath:(NSString *)inPath;
{
    BOOL isDir = NO;
    if (![self fileExistsAtPath:inPath isDirectory:&isDir]) {
        return 0;
    }
    
    unsigned long long totalSize = 0;
    
    if (isDir) {
        NSDirectoryEnumerator *directoryEnum = [self enumeratorAtPath:inPath];
        NSString *currentItemPath;
        while (currentItemPath = [directoryEnum nextObject]) {
            if ([[[directoryEnum fileAttributes] fileType] isEqualToString:NSFileTypeDirectory]) {
                totalSize += [self BCC_fileSizeAtPath:[inPath stringByAppendingPathComponent:currentItemPath]];
            } else {
                totalSize += [[directoryEnum fileAttributes] fileSize];                
            }
        }
    } else {
        NSDictionary *fileAttributes = [self attributesOfItemAtPath:inPath error:NULL];
        totalSize = fileAttributes.count ? [fileAttributes fileSize] : 0;
    }
    
    return totalSize;
}

- (NSDate *)BCC_modificationDateForFileAtPath:(NSString *)inPath;
{
    struct stat fileAttributesStruct;
    stat([inPath UTF8String], &fileAttributesStruct);
    return [NSDate BCC_dateWithCTimeStruct:fileAttributesStruct.st_mtime];
}

@end
