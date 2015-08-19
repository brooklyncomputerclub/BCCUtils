//
//  NSFileManager+BCCAdditions.h
//
//  Created by Buzz Andersen on 2/19/11.
//  Copyright 2012 Brooklyn Computer Club. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (BCCAdditions)

// Support Directory Paths
- (NSString *)BCC_cachePath;
- (NSString *)BCC_cachePathIncludingAppName;
- (NSString *)BCC_cacheFileName:(NSString *)fileName;
- (NSString *)BCC_applicationSupportPath;
- (NSString *)BCC_applicationSupportPathIncludingAppName;
- (NSString *)BCC_applicationSupportFileName:(NSString *)fileName;

// Recursive Directory Creation
- (BOOL)BCC_recursivelyCreatePath:(NSString *)inPath;
- (BOOL)BCC_recursivelyCreatePath:(NSString *)inPath lastComponentIsFile:(BOOL)isFile;

// File Attributes
- (unsigned long long)BCC_fileSizeAtPath:(NSString *)inPath;
- (NSDate *)BCC_modificationDateForFileAtPath:(NSString *)inPath;

@end
