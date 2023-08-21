//
//  IRHCDataResponse.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataResponse.h"
#import "IRHCData+Internal.h"
#import "IRHCLog.h"

@implementation IRHCDataResponse

- (instancetype)initWithURL:(NSURL *)URL headers:(NSDictionary *)headers
{
    if (self = [super init]) {
        IRHCLogAlloc(self);
        self->_URL = URL;
        self->_headers = headers;
        self->_contentType = [self headerValueWithKey:@"Content-Type"];
        self->_contentRangeString = [self headerValueWithKey:@"Content-Range"];
        self->_contentLength = [self headerValueWithKey:@"Content-Length"].longLongValue;
        self->_contentRange = IRHCRangeWithResponseHeaderValue(self.contentRangeString, &self->_totalLength);
        IRHCLogDataResponse(@"%p Create data response\nURL : %@\nHeaders : %@\ncontentType : %@\ntotalLength : %lld\ncurrentLength : %lld", self, self.URL, self.headers, self.contentType, self.totalLength, self.contentLength);
    }
    return self;
}

- (void)dealloc
{
    IRHCLogDealloc(self);
}

- (NSString *)headerValueWithKey:(NSString *)key
{
    NSString *value = [self.headers objectForKey:key];
    if (!value) {
        value = [self.headers objectForKey:[key lowercaseString]];
    }
    return value;
}

@end

