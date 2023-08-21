//
//  IRHCDataUnitPool.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCDataUnit.h"
#import "IRHCDataCacheItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRHCDataUnitPool : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)pool;

- (IRHCDataUnit *)unitWithURL:(NSURL *)URL;

- (long long)totalCacheLength;

- (NSArray<IRHCDataCacheItem *> *)allCacheItem;
- (IRHCDataCacheItem *)cacheItemWithURL:(NSURL *)URL;

- (void)deleteUnitWithURL:(NSURL *)URL;
- (void)deleteUnitsWithLength:(long long)length;
- (void)deleteAllUnits;

@end

NS_ASSUME_NONNULL_END
