//
//  IRHCPathTool.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRHCPathTool : NSObject

+ (NSString *)logPath;
+ (NSString *)archivePath;
+ (NSString *)directoryPathWithURL:(NSURL *)URL;
+ (NSString *)completeFilePathWithURL:(NSURL *)URL;
+ (NSString *)filePathWithURL:(NSURL *)URL offset:(long long)offset;
+ (NSString *)converToRelativePath:(NSString *)path;
+ (NSString *)converToAbsoultePath:(NSString *)path;

+ (void)createFileAtPath:(NSString *)path;
+ (void)createDirectoryAtPath:(NSString *)path;
+ (NSError *)deleteFileAtPath:(NSString *)path;
+ (NSError *)deleteDirectoryAtPath:(NSString *)path;

+ (long long)sizeAtPath:(NSString *)path;

@end


NS_ASSUME_NONNULL_END
