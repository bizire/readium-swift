//
//  IRHCDataCacheItemZone.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataCacheItemZone.h"
#import "IRHCData+Internal.h"

@implementation IRHCDataCacheItemZone

- (instancetype)initWithOffset:(long long)offset length:(long long)length
{
    if (self = [super init]) {
        self->_offset = offset;
        self->_length = length;
    }
    return self;
}

@end
