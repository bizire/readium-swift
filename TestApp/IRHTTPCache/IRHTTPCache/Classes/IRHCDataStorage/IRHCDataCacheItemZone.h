//
//  IRHCDataCacheItemZone.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRHCDataCacheItemZone : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, readonly) long long offset;
@property (nonatomic, readonly) long long length;

@end

NS_ASSUME_NONNULL_END
