//
//  IRHTTPCache.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/30.
//

#import "IRHTTPCache.h"
#import "IRHCDataStorage.h"
#import "IRHCHTTPServer.h"
#import "IRHCDownload.h"
#import "IRHCURLTool.h"
#import "IRHCLog.h"

@implementation IRHTTPCache

#pragma mark - HTTP Server

+ (BOOL)proxyStart:(NSError **)error
{
    return [[IRHCHTTPServer server] start:error];
}

+ (void)proxyStop
{
    [[IRHCHTTPServer server] stop];
}

+ (BOOL)proxyIsRunning
{
    return [IRHCHTTPServer server].isRunning;
}

+ (NSURL *)proxyURLWithOriginalURL:(NSURL *)URL
{
    return [[IRHCHTTPServer server] URLWithOriginalURL:URL];
}

#pragma mark - Data Storage

+ (NSURL *)cacheCompleteFileURLWithURL:(NSURL *)URL
{
    return [[IRHCDataStorage storage] completeFileURLWithURL:URL];
}

+ (IRHCDataReader *)cacheReaderWithRequest:(IRHCDataRequest *)request
{
    return [[IRHCDataStorage storage] readerWithRequest:request];
}

+ (IRHCDataLoader *)cacheLoaderWithRequest:(IRHCDataRequest *)request
{
    return [[IRHCDataStorage storage] loaderWithRequest:request];
}

+ (void)cacheSetMaxCacheLength:(long long)maxCacheLength
{
    [IRHCDataStorage storage].maxCacheLength = maxCacheLength;
}

+ (long long)cacheMaxCacheLength
{
    return [IRHCDataStorage storage].maxCacheLength;
}

+ (long long)cacheTotalCacheLength
{
    return [IRHCDataStorage storage].totalCacheLength;
}

+ (IRHCDataCacheItem *)cacheCacheItemWithURL:(NSURL *)URL
{
    return [[IRHCDataStorage storage] cacheItemWithURL:URL];
}

+ (NSArray<IRHCDataCacheItem *> *)cacheAllCacheItems
{
    return [[IRHCDataStorage storage] allCacheItems];
}

+ (void)cacheDeleteCacheWithURL:(NSURL *)URL
{
    [[IRHCDataStorage storage] deleteCacheWithURL:URL];
}

+ (void)cacheDeleteAllCaches
{
    [[IRHCDataStorage storage] deleteAllCaches];
}

#pragma mark - Encode

+ (void)encodeSetURLConverter:(NSURL * (^)(NSURL *URL))URLConverter;
{
    [IRHCURLTool tool].URLConverter = URLConverter;
}

#pragma mark - Download

+ (void)downloadSetTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    [IRHCDownload download].timeoutInterval = timeoutInterval;
}

+ (NSTimeInterval)downloadTimeoutInterval
{
    return [IRHCDownload download].timeoutInterval;
}

+ (void)downloadSetWhitelistHeaderKeys:(NSArray<NSString *> *)whitelistHeaderKeys
{
    [IRHCDownload download].whitelistHeaderKeys = whitelistHeaderKeys;
}

+ (NSArray<NSString *> *)downloadWhitelistHeaderKeys
{
    return [IRHCDownload download].whitelistHeaderKeys;
}

+ (void)downloadSetAdditionalHeaders:(NSDictionary<NSString *, NSString *> *)additionalHeaders
{
    [IRHCDownload download].additionalHeaders = additionalHeaders;
}

+ (NSDictionary<NSString *, NSString *> *)downloadAdditionalHeaders
{
    return [IRHCDownload download].additionalHeaders;
}

+ (void)downloadSetAcceptableContentTypes:(NSArray<NSString *> *)acceptableContentTypes
{
    [IRHCDownload download].acceptableContentTypes = acceptableContentTypes;
}

+ (NSArray<NSString *> *)downloadAcceptableContentTypes
{
    return [IRHCDownload download].acceptableContentTypes;
}

+ (void)downloadSetUnacceptableContentTypeDisposer:(BOOL(^)(NSURL *URL, NSString *contentType))unacceptableContentTypeDisposer
{
    [IRHCDownload download].unacceptableContentTypeDisposer = unacceptableContentTypeDisposer;
}

#pragma mark - Log

+ (void)logAddLog:(NSString *)log
{
    if (log.length > 0) {
        IRHCLogCommon(@"%@", log);
    }
}

+ (void)logSetConsoleLogEnable:(BOOL)consoleLogEnable
{
    [IRHCLog log].consoleLogEnable = consoleLogEnable;
}

+ (BOOL)logConsoleLogEnable
{
    return [IRHCLog log].consoleLogEnable;
}

+ (BOOL)logRecordLogEnable
{
    return [IRHCLog log].recordLogEnable;
}

+ (NSURL *)logRecordLogFileURL
{
    return [IRHCLog log].recordLogFileURL;
}

+ (void)logSetRecordLogEnable:(BOOL)recordLogEnable
{
    [IRHCLog log].recordLogEnable = recordLogEnable;
}

+ (void)logDeleteRecordLogFile
{
    [[IRHCLog log] deleteRecordLogFile];
}

+ (NSDictionary<NSURL *, NSError *> *)logErrors
{
    return [[IRHCLog log] errors];
}

+ (void)logCleanErrorForURL:(NSURL *)URL
{
    [[IRHCLog log] cleanErrorForURL:URL];
}

+ (NSError *)logErrorForURL:(NSURL *)URL
{
    return [[IRHCLog log] errorForURL:URL];
}

@end

#pragma mark - Deprecated

@implementation IRHTTPCache (Deprecated)

+ (void)logDeleteRecordLog
{
    [self logDeleteRecordLogFile];
}

+ (NSString *)logRecordLogFilePath
{
    return [self logRecordLogFileURL].path;
}

+ (NSString *)proxyURLStringWithOriginalURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    return [self proxyURLWithOriginalURL:URL].absoluteString;
}

+ (NSURL *)cacheCompleteFileURLIfExistedWithURL:(NSURL *)URL
{
    return [self cacheCompleteFileURLWithURL:URL];
}

+ (NSString *)cacheCompleteFilePathIfExistedWithURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    return [self cacheCompleteFileURLWithURL:URL].path;
}

+ (IRHCDataCacheItem *)cacheCacheItemWithURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    return [self cacheCacheItemWithURL:URL];
}

+ (void)cacheDeleteCacheWithURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    [self cacheDeleteCacheWithURL:URL];
}

+ (void)tokenSetURLFilter:(NSURL * (^)(NSURL *URL))URLFilter
{
    [self encodeSetURLConverter:URLFilter];
}

+ (void)downloadSetAcceptContentTypes:(NSArray<NSString *> *)acceptContentTypes
{
    [self downloadSetAcceptableContentTypes:acceptContentTypes];
}

+ (NSArray<NSString *> *)downloadAcceptContentTypes
{
    return [self downloadAcceptableContentTypes];
}

+ (void)downloadSetUnsupportContentTypeFilter:(BOOL(^)(NSURL *URL, NSString *contentType))contentTypeFilter
{
    [self downloadSetUnacceptableContentTypeDisposer:contentTypeFilter];
}

@end

