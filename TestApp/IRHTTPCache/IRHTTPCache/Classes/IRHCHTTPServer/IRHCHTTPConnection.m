//
//  IRHCHTTPConnection.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/29.
//

#import "IRHCHTTPConnection.h"
#import "IRHCHTTPResponse.h"
#import "IRHCDataStorage.h"
#import "IRHCURLTool.h"
#import "IRHCLog.h"

@implementation IRHCHTTPConnection

- (id)initWithAsyncSocket:(GCDAsyncSocket *)newSocket configuration:(HTTPConfig *)aConfig
{
    if (self = [super initWithAsyncSocket:newSocket configuration:aConfig]) {
        IRHCLogAlloc(self);
    }
    return self;
}

- (void)dealloc
{
    IRHCLogDealloc(self);
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    IRHCLogHTTPConnection(@"%p, Receive request\nmethod : %@\npath : %@\nURL : %@", self, method, path, request.url);
    NSDictionary<NSString *,NSString *> *parameters = [[IRHCURLTool tool] parseQuery:request.url.query];
    NSURL *URL = [NSURL URLWithString:[parameters objectForKey:@"url"]];
    IRHCDataRequest *dataRequest = [[IRHCDataRequest alloc] initWithURL:URL headers:request.allHeaderFields];
    IRHCHTTPResponse *response = [[IRHCHTTPResponse alloc] initWithConnection:self dataRequest:dataRequest];
    return response;
}


@end

