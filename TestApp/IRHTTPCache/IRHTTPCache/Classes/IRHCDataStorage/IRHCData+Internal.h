//
//  IRHCData+Internal.h.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCDataCacheItemZone.h"
#import "IRHCDataCacheItem.h"
#import "IRHCDataResponse.h"
#import "IRHCDataRequest.h"
#import "IRHCDataReader.h"
#import "IRHCDataLoader.h"

#pragma mark - IRHCDataReader

@interface IRHCDataReader ()

- (instancetype)initWithRequest:(IRHCDataRequest *)request NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - IRHCDataLoader

@interface IRHCDataLoader ()

- (instancetype)initWithRequest:(IRHCDataRequest *)request NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - IRHCDataRequest

@interface IRHCDataRequest ()

- (IRHCDataRequest *)newRequestWithRange:(IRHCRange)range;
- (IRHCDataRequest *)newRequestWithTotalLength:(long long)totalLength;

@end

#pragma mark - IRHCDataResponse

@interface IRHCDataResponse ()

- (instancetype)initWithURL:(NSURL *)URL headers:(NSDictionary *)headers NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - IRHCDataCacheItem

@interface IRHCDataCacheItem ()

- (instancetype)initWithURL:(NSURL *)URL
                      zones:(NSArray<IRHCDataCacheItemZone *> *)zones
                totalLength:(long long)totalLength
                cacheLength:(long long)cacheLength
                vaildLength:(long long)vaildLength NS_DESIGNATED_INITIALIZER;

@end

#pragma mark - IRHCDataCacheItemZone

@interface IRHCDataCacheItemZone ()

- (instancetype)initWithOffset:(long long)offset length:(long long)length NS_DESIGNATED_INITIALIZER;

@end
