//
//  IRHCDataLoader.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataLoader.h"
#import "IRHCData+Internal.h"
#import "IRHCLog.h"

@interface IRHCDataLoader () <IRHCDataReaderDelegate>

@property (nonatomic, strong) IRHCDataReader *reader;

@end

@implementation IRHCDataLoader

- (instancetype)initWithRequest:(IRHCDataRequest *)request
{
    if (self = [super init]) {
        IRHCLogAlloc(self);
        self.reader = [[IRHCDataReader alloc] initWithRequest:request];
        self.reader.delegate = self;
        IRHCLogDataLoader(@"%p, Create loader\norignalRequest : %@\nreader : %@", self, request, self.reader);
    }
    return self;
}

- (void)dealloc
{
    IRHCLogDealloc(self);
    [self close];
    IRHCLogDataLoader(@"%p, Destory reader\nError : %@\nprogress : %f", self, self.error, self.progress);
}

- (void)prepare
{
    IRHCLogDataLoader(@"%p, Call prepare", self);
    [self.reader prepare];
}

- (void)close
{
    IRHCLogDataLoader(@"%p, Call close", self);
    [self.reader close];
}

- (IRHCDataRequest *)request
{
    return self.reader.request;
}

- (IRHCDataResponse *)response
{
    return self.reader.response;
}

- (NSError *)error
{
    return self.reader.error;
}

- (BOOL)isFinished
{
    return self.reader.isFinished;
}

- (BOOL)isClosed
{
    return self.reader.isClosed;
}

#pragma mark - IRHCDataReaderDelegate

- (void)ir_readerDidPrepare:(IRHCDataReader *)reader
{
    [self readData];
}

- (void)ir_readerHasAvailableData:(IRHCDataReader *)reader
{
    [self readData];
}

- (void)ir_reader:(IRHCDataReader *)reader didFailWithError:(NSError *)error
{
    IRHCLogDataLoader(@"%p, Callback for failed", self);
    if ([self.delegate respondsToSelector:@selector(ir_loader:didFailWithError:)]) {
        [self.delegate ir_loader:self didFailWithError:error];
    }
}

- (void)readData
{
    while (YES) {
        @autoreleasepool {
            NSData *data = [self.reader readDataOfLength:1024 * 1024 * 1];
            if (self.reader.isFinished) {
                self->_loadedLength = self.reader.readedLength;
                self->_progress = 1.0f;
                if ([self.delegate respondsToSelector:@selector(ir_loader:didChangeProgress:)]) {
                    [self.delegate ir_loader:self didChangeProgress:self.progress];
                }
                IRHCLogDataLoader(@"%p, Callback finished", self);
                if ([self.delegate respondsToSelector:@selector(ir_loaderDidFinish:)]) {
                    [self.delegate ir_loaderDidFinish:self];
                }
            } else if (data) {
                self->_loadedLength = self.reader.readedLength;
                if (self.response.contentLength > 0) {
                    self->_progress = (double)self.reader.readedLength / (double)self.response.contentLength;
                }
                if ([self.delegate respondsToSelector:@selector(ir_loader:didChangeProgress:)]) {
                    [self.delegate ir_loader:self didChangeProgress:self.progress];
                }
                IRHCLogDataLoader(@"%p, read data progress %f", self, self.progress);
                continue;
            }
            IRHCLogDataLoader(@"%p, read data break", self);
            break;
        }
    }
}

@end
