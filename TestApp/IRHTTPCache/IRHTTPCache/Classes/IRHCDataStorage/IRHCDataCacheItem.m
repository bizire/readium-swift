//
//  IRHCDataCacheItem.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataCacheItem.h"
#import "IRHCData+Internal.h"

@implementation IRHCDataCacheItem

- (instancetype)initWithURL:(NSURL *)URL
                      zones:(NSArray<IRHCDataCacheItemZone *> *)zones
                totalLength:(long long)totalLength
                cacheLength:(long long)cacheLength
                vaildLength:(long long)vaildLength
{
    if (self = [super init]) {
        self->_URL = [URL copy];
        self->_zones = [zones copy];
        self->_totalLength = totalLength;
        self->_cacheLength = cacheLength;
        self->_vaildLength = vaildLength;
    }
    return self;
}

@end

