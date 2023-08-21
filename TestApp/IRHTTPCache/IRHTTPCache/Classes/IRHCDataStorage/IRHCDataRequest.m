//
//  IRHCDataRequest.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataRequest.h"
#import "IRHCData+Internal.h"
#import "IRHCLog.h"

@implementation IRHCDataRequest

- (instancetype)initWithURL:(NSURL *)URL headers:(NSDictionary *)headers
{
    if (self = [super init]) {
        IRHCLogAlloc(self);
        self->_URL = URL;
        self->_headers = IRHCRangeFillToRequestHeadersIfNeeded(IRHCRangeFull(), headers);
        self->_range = IRHCRangeWithRequestHeaderValue([self.headers objectForKey:@"Range"]);
        IRHCLogDataRequest(@"%p Create data request\nURL : %@\nHeaders : %@\nRange : %@", self, self.URL, self.headers, IRHCStringFromRange(self.range));
    }
    return self;
}

- (void)dealloc
{
    IRHCLogDealloc(self);
}

- (IRHCDataRequest *)newRequestWithRange:(IRHCRange)range
{
    NSDictionary *headers = IRHCRangeFillToRequestHeaders(range, self.headers);
    IRHCDataRequest *obj = [[IRHCDataRequest alloc] initWithURL:self.URL headers:headers];
    return obj;
}

- (IRHCDataRequest *)newRequestWithTotalLength:(long long)totalLength
{
    IRHCRange range = IRHCRangeWithEnsureLength(self.range, totalLength);
    return [self newRequestWithRange:range];
}

@end

