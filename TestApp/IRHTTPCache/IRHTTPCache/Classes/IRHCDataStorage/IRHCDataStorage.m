//
//  IRHCDataStorage.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataStorage.h"
#import "IRHCData+Internal.h"
#import "IRHCDataUnitPool.h"
#import "IRHCLog.h"

@implementation IRHCDataStorage

+ (instancetype)storage
{
    static IRHCDataStorage *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.maxCacheLength = 500 * 1024 * 1024;
    }
    return self;
}

- (NSURL *)completeFileURLWithURL:(NSURL *)URL
{
    IRHCDataUnit *unit = [[IRHCDataUnitPool pool] unitWithURL:URL];
    NSURL *completeURL = unit.completeURL;
    [unit workingRelease];
    return completeURL;
}

- (IRHCDataReader *)readerWithRequest:(IRHCDataRequest *)request
{
    if (!request || request.URL.absoluteString.length <= 0) {
        IRHCLogDataStorage(@"Invaild reader request, %@", request.URL);
        return nil;
    }
    IRHCDataReader *reader = [[IRHCDataReader alloc] initWithRequest:request];
    return reader;
}

- (IRHCDataLoader *)loaderWithRequest:(IRHCDataRequest *)request
{
    if (!request || request.URL.absoluteString.length <= 0) {
        IRHCLogDataStorage(@"Invaild loader request, %@", request.URL);
        return nil;
    }
    IRHCDataLoader *loader = [[IRHCDataLoader alloc] initWithRequest:request];
    return loader;
}

- (IRHCDataCacheItem *)cacheItemWithURL:(NSURL *)URL
{
    return [[IRHCDataUnitPool pool] cacheItemWithURL:URL];
}

- (NSArray<IRHCDataCacheItem *> *)allCacheItems
{
    return [[IRHCDataUnitPool pool] allCacheItem];
}

- (long long)totalCacheLength
{
    return [[IRHCDataUnitPool pool] totalCacheLength];
}

- (void)deleteCacheWithURL:(NSURL *)URL
{
    [[IRHCDataUnitPool pool] deleteUnitWithURL:URL];
}

- (void)deleteAllCaches
{
    [[IRHCDataUnitPool pool] deleteAllUnits];
}

@end

