//
//  IRHCDataSourceManager.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataSourceManager.h"
#import "IRHCDataCallback.h"
#import "IRHCLog.h"

@interface IRHCDataSourceManager () <NSLocking, IRHCDataFileSourceDelegate, IRHCDataNetworkSourceDelegate>

@property (nonatomic, strong) NSLock *coreLock;
@property (nonatomic, strong) id <IRHCDataSource> currentSource;
@property (nonatomic, strong) IRHCDataNetworkSource *currentNetworkSource;
@property (nonatomic, strong) NSMutableArray<id<IRHCDataSource>> *sources;
@property (nonatomic) BOOL calledPrepare;
@property (nonatomic) BOOL calledReceiveResponse;

@end

@implementation IRHCDataSourceManager

@synthesize error = _error;
@synthesize range = _range;
@synthesize closed = _closed;
@synthesize prepared = _prepared;
@synthesize finished = _finished;
@synthesize readedLength = _readedLength;

- (instancetype)initWithSources:(NSArray<id<IRHCDataSource>> *)sources delegate:(id<IRHCDataSourceManagerDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    if (self = [super init]) {
        IRHCLogAlloc(self);
        self->_sources = [sources mutableCopy];
        self->_delegate = delegate;
        self->_delegateQueue = delegateQueue;
    }
    return self;
}

- (void)dealloc
{
    IRHCLogDealloc(self);
    IRHCLogDataReader(@"%p, Destory reader\nError : %@\ncurrentSource : %@\ncurrentNetworkSource : %@", self, self.error, self.currentSource, self.currentNetworkSource);
}

- (void)prepare
{
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return;
    }
    if (self.calledPrepare) {
        [self unlock];
        return;
    }
    self->_calledPrepare = YES;
    IRHCLogDataSourceManager(@"%p, Call prepare", self);
    IRHCLogDataSourceManager(@"%p, Sort sources - Begin\nSources : %@", self, self.sources);
    [self.sources sortUsingComparator:^NSComparisonResult(id <IRHCDataSource> obj1, id <IRHCDataSource> obj2) {
        if (obj1.range.start < obj2.range.start) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    IRHCLogDataSourceManager(@"%p, Sort sources - End  \nSources : %@", self, self.sources);
    for (id <IRHCDataSource> obj in self.sources) {
        if ([obj isKindOfClass:[IRHCDataFileSource class]]) {
            IRHCDataFileSource *source = (IRHCDataFileSource *)obj;
            [source setDelegate:self delegateQueue:self.delegateQueue];
        }
        else if ([obj isKindOfClass:[IRHCDataNetworkSource class]]) {
            IRHCDataNetworkSource *source = (IRHCDataNetworkSource *)obj;
            [source setDelegate:self delegateQueue:self.delegateQueue];
        }
    }
    self.currentSource = self.sources.firstObject;
    for (id<IRHCDataSource> obj in self.sources) {
        if ([obj isKindOfClass:[IRHCDataNetworkSource class]]) {
            self.currentNetworkSource = obj;
            break;
        }
    }
    IRHCLogDataSourceManager(@"%p, Sort source\ncurrentSource : %@\ncurrentNetworkSource : %@", self, self.currentSource, self.currentNetworkSource);
    [self.currentSource prepare];
    [self.currentNetworkSource prepare];
    [self unlock];
}

- (void)close
{
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return;
    }
    self->_closed = YES;
    IRHCLogDataSourceManager(@"%p, Call close", self);
    for (id <IRHCDataSource> obj in self.sources) {
        [obj close];
    }
    [self unlock];
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return nil;
    }
    if (self.isFinished) {
        [self unlock];
        return nil;
    }
    if (self.error) {
        [self unlock];
        return nil;
    }
    NSData *data = [self.currentSource readDataOfLength:length];
    self->_readedLength += data.length;
    IRHCLogDataSourceManager(@"%p, Read data : %lld", self, (long long)data.length);
    if (self.currentSource.isFinished) {
        self.currentSource = [self nextSource];
        if (self.currentSource) {
            IRHCLogDataSourceManager(@"%p, Switch to next source, %@", self, self.currentSource);
            if ([self.currentSource isKindOfClass:[IRHCDataFileSource class]]) {
                [self.currentSource prepare];
            }
        } else {
            IRHCLogDataSourceManager(@"%p, Read data did finished", self);
            self->_finished = YES;
        }
    }
    [self unlock];
    return data;
}

- (id<IRHCDataSource>)nextSource
{
    NSUInteger index = [self.sources indexOfObject:self.currentSource] + 1;
    if (index < self.sources.count) {
        IRHCLogDataSourceManager(@"%p, Fetch next source : %@", self, [self.sources objectAtIndex:index]);
        return [self.sources objectAtIndex:index];
    }
    IRHCLogDataSourceManager(@"%p, Fetch netxt source failed", self);
    return nil;
}

- (IRHCDataNetworkSource *)nextNetworkSource
{
    NSUInteger index = [self.sources indexOfObject:self.currentNetworkSource] + 1;
    for (; index < self.sources.count; index++) {
        id <IRHCDataSource> obj = [self.sources objectAtIndex:index];
        if ([obj isKindOfClass:[IRHCDataNetworkSource class]]) {
            IRHCLogDataSourceManager(@"%p, Fetch next network source : %@", self, obj);
            return obj;
        }
    }
    IRHCLogDataSourceManager(@"%p, Fetch netxt network source failed", self);
    return nil;
}

#pragma mark - IRHCDataFileSourceDelegate

- (void)ir_fileSourceDidPrepare:(IRHCDataFileSource *)fileSource
{
    [self lock];
    [self callbackForPrepared];
    [self unlock];
}

- (void)ir_fileSource:(IRHCDataFileSource *)fileSource didFailWithError:(NSError *)error
{
    [self callbackForFailed:error];
}

#pragma mark - IRHCDataNetworkSourceDelegate

- (void)ir_networkSourceDidPrepare:(IRHCDataNetworkSource *)networkSource
{
    [self lock];
    [self callbackForPrepared];
    [self callbackForReceiveResponse:networkSource.response];
    [self unlock];
}

- (void)ir_networkSourceHasAvailableData:(IRHCDataNetworkSource *)networkSource
{
    [self lock];
    if ([self.delegate respondsToSelector:@selector(ir_sourceManagerHasAvailableData:)]) {
        IRHCLogDataSourceManager(@"%p, Callback for has available data - Begin\nSource : %@", self, networkSource);
        [IRHCDataCallback callbackWithQueue:self.delegateQueue block:^{
            IRHCLogDataSourceManager(@"%p, Callback for has available data - End", self);
            [self.delegate ir_sourceManagerHasAvailableData:self];
        }];
    }
    [self unlock];
}

- (void)ir_networkSourceDidFinisheDownload:(IRHCDataNetworkSource *)networkSource
{
    [self lock];
    self.currentNetworkSource = [self nextNetworkSource];
    [self.currentNetworkSource prepare];
    [self unlock];
}

- (void)ir_networkSource:(IRHCDataNetworkSource *)networkSource didFailWithError:(NSError *)error
{
    [self callbackForFailed:error];
}

#pragma mark - Callback

- (void)callbackForPrepared
{
    if (self.isClosed) {
        return;
    }
    if (self.isPrepared) {
        return;
    }
    self->_prepared = YES;
    if ([self.delegate respondsToSelector:@selector(ir_sourceManagerDidPrepare:)]) {
        IRHCLogDataSourceManager(@"%p, Callback for prepared - Begin", self);
        [IRHCDataCallback callbackWithQueue:self.delegateQueue block:^{
            IRHCLogDataSourceManager(@"%p, Callback for prepared - End", self);
            [self.delegate ir_sourceManagerDidPrepare:self];
        }];
    }
}

- (void)callbackForReceiveResponse:(IRHCDataResponse *)response
{
    if (self.isClosed) {
        return;
    }
    if (self.calledReceiveResponse) {
        return;
    }
    self->_calledReceiveResponse = YES;
    if ([self.delegate respondsToSelector:@selector(ir_sourceManager:didReceiveResponse:)]) {
        IRHCLogDataSourceManager(@"%p, Callback for did receive response - End", self);
        [IRHCDataCallback callbackWithQueue:self.delegateQueue block:^{
            IRHCLogDataSourceManager(@"%p, Callback for did receive response - End", self);
            [self.delegate ir_sourceManager:self didReceiveResponse:response];
        }];
    }
}

- (void)callbackForFailed:(NSError *)error
{
    if (!error) {
        return;
    }
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return;
    }
    if (self.error) {
        [self unlock];
        return;
    }
    self->_error = error;
    IRHCLogDataSourceManager(@"failure, %d", (int)self.error.code);
    if (self.error && [self.delegate respondsToSelector:@selector(ir_sourceManager:didFailWithError:)]) {
        IRHCLogDataSourceManager(@"%p, Callback for network source failed - Begin\nError : %@", self, self.error);
        [IRHCDataCallback callbackWithQueue:self.delegateQueue block:^{
            IRHCLogDataSourceManager(@"%p, Callback for network source failed - End", self);
            [self.delegate ir_sourceManager:self didFailWithError:self.error];
        }];
    }
    [self unlock];
}

#pragma mark - NSLocking

- (void)lock
{
    if (!self.coreLock) {
        self.coreLock = [[NSLock alloc] init];
    }
    [self.coreLock lock];
}

- (void)unlock
{
    [self.coreLock unlock];
}

@end

