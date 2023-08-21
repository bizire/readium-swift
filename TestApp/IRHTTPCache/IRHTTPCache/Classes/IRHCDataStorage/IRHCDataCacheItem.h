//
//  IRHCDataCacheItem.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IRHCDataCacheItemZone;

@interface IRHCDataCacheItem : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSArray<IRHCDataCacheItemZone *> *zones;

@property (nonatomic, readonly) long long totalLength;
@property (nonatomic, readonly) long long cacheLength;
@property (nonatomic, readonly) long long vaildLength;

@end

NS_ASSUME_NONNULL_END
