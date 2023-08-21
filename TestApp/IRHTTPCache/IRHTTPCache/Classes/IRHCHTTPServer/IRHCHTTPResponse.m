//
//  IRHCHTTPResponse.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/29.
//

#import "IRHCHTTPResponse.h"
#import "IRHCHTTPConnection.h"
#import "IRHCDataStorage.h"
#import "IRHCLog.h"

@interface IRHCHTTPResponse () <IRHCDataReaderDelegate>

@property (nonatomic) BOOL waitingResponse;
@property (nonatomic, strong) IRHCDataReader *reader;
@property (nonatomic, weak) IRHCHTTPConnection *connection;

@end

@implementation IRHCHTTPResponse

- (instancetype)initWithConnection:(IRHCHTTPConnection *)connection dataRequest:(IRHCDataRequest *)dataRequest
{
    if (self = [super init]) {
        IRHCLogAlloc(self);
        self.connection = connection;
        self.reader = [[IRHCDataStorage storage] readerWithRequest:dataRequest];
        self.reader.delegate = self;
        [self.reader prepare];
        IRHCLogHTTPResponse(@"%p, Create response\nrequest : %@", self, dataRequest);
    }
    return self;
}

- (void)dealloc
{
    [self.reader close];
    IRHCLogDealloc(self);
}

#pragma mark - HTTPResponse

- (NSData *)readDataOfLength:(NSUInteger)length
{
    NSData *data = [self.reader readDataOfLength:length];
    IRHCLogHTTPResponse(@"%p, Read data : %lld", self, (long long)data.length);
    if (self.reader.isFinished) {
        IRHCLogHTTPResponse(@"%p, Read data did finished", self);
        [self.reader close];
        [self.connection responseDidAbort:self];
    }
    return data;
}

- (BOOL)delayResponseHeaders
{
    BOOL waiting = !self.reader.isPrepared;
    self.waitingResponse = waiting;
    IRHCLogHTTPResponse(@"%p, Delay response : %d", self, self.waitingResponse);
    return waiting;
}

- (UInt64)contentLength
{
    IRHCLogHTTPResponse(@"%p, Conetnt length : %lld", self, self.reader.response.totalLength);
    return self.reader.response.totalLength;
}

- (NSDictionary *)httpHeaders
{
    NSMutableDictionary *headers = [self.reader.response.headers mutableCopy];
    [headers removeObjectForKey:@"Content-Range"];
    [headers removeObjectForKey:@"content-range"];
    [headers removeObjectForKey:@"Content-Length"];
    [headers removeObjectForKey:@"content-length"];
    IRHCLogHTTPResponse(@"%p, Header\n%@", self, headers);
    return headers;
}

- (UInt64)offset
{
    IRHCLogHTTPResponse(@"%p, Offset : %lld", self, self.reader.readedLength);
    return self.reader.readedLength;
}

- (void)setOffset:(UInt64)offset
{
    IRHCLogHTTPResponse(@"%p, Set offset : %lld, %lld", self, offset, self.reader.readedLength);
}

- (BOOL)isDone
{
    IRHCLogHTTPResponse(@"%p, Check done : %d", self, self.reader.isFinished);
    return self.reader.isFinished;
}

- (void)connectionDidClose
{
    IRHCLogHTTPResponse(@"%p, Connection did closed : %lld, %lld", self, self.reader.response.contentLength, self.reader.readedLength);
    [self.reader close];
}

#pragma mark - IRHCDataReaderDelegate

- (void)ir_readerDidPrepare:(IRHCDataReader *)reader
{
    IRHCLogHTTPResponse(@"%p, Prepared", self);
    if (self.reader.isPrepared && self.waitingResponse == YES) {
        IRHCLogHTTPResponse(@"%p, Call connection did prepared", self);
        [self.connection responseHasAvailableData:self];
    }
}

- (void)ir_readerHasAvailableData:(IRHCDataReader *)reader
{
    IRHCLogHTTPResponse(@"%p, Has available data", self);
    [self.connection responseHasAvailableData:self];
}

- (void)ir_reader:(IRHCDataReader *)reader didFailWithError:(NSError *)error
{
    IRHCLogHTTPResponse(@"%p, Failed\nError : %@", self, error);
    [self.reader close];
    [self.connection responseDidAbort:self];
}

@end

