//
//  IRHCDataStorage.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCDataReader.h"
#import "IRHCDataLoader.h"
#import "IRHCDataRequest.h"
#import "IRHCDataResponse.h"
#import "IRHCDataCacheItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRHCDataStorage : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)storage;

/**
 *  Return file path if the content did finished cache.
 */
- (NSURL *)completeFileURLWithURL:(NSURL *)URL;

/**
 *  Reader for certain request.
 */
- (IRHCDataReader *)readerWithRequest:(IRHCDataRequest *)request;

/**
 *  Loader for certain request.
 */
- (IRHCDataLoader *)loaderWithRequest:(IRHCDataRequest *)request;

/**
 *  Get cache item.
 */
- (IRHCDataCacheItem *)cacheItemWithURL:(NSURL *)URL;
- (NSArray<IRHCDataCacheItem *> *)allCacheItems;

/**
 *  Get cache length.
 */
@property (nonatomic) long long maxCacheLength;     // Default is 500M.
- (long long)totalCacheLength;

/**
 *  Delete cache.
 */
- (void)deleteCacheWithURL:(NSURL *)URL;
- (void)deleteAllCaches;

@end


NS_ASSUME_NONNULL_END
