//
//  IRHCDataReader.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataReader.h"
#import "IRHCData+Internal.h"
#import "IRHCDataSourceManager.h"
#import "IRHCDataUnitPool.h"
#import "IRHCDataCallback.h"
#import "IRHCLog.h"

@interface IRHCDataReader () <IRHCDataSourceManagerDelegate>

@property (nonatomic, strong) IRHCDataUnit *unit;
@property (nonatomic, strong) NSRecursiveLock *coreLock;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) dispatch_queue_t internalDelegateQueue;
@property (nonatomic, strong) IRHCDataSourceManager *sourceManager;
@property (nonatomic) BOOL calledPrepare;

@end

@implementation IRHCDataReader

- (instancetype)initWithRequest:(IRHCDataRequest *)request
{
    if (self = [super init]) {
        IRHCLogAlloc(self);
        self.unit = [[IRHCDataUnitPool pool] unitWithURL:request.URL];
        self->_request = [request newRequestWithTotalLength:self.unit.totalLength];
        self.delegateQueue = dispatch_queue_create("IRHCDataReader_delegateQueue", DISPATCH_QUEUE_SERIAL);
        self.internalDelegateQueue = dispatch_queue_create("IRHCDataReader_internalDelegateQueue", DISPATCH_QUEUE_SERIAL);
        IRHCLogDataReader(@"%p, Create reader\norignalRequest : %@\nfinalRequest : %@\nUnit : %@", self, request, self.request, self.unit);
    }
    return self;
}

- (void)dealloc
{
    IRHCLogDealloc(self);
    [self close];
    IRHCLogDataReader(@"%p, Destory reader\nError : %@\nreadOffset : %lld", self, self.error, self.readedLength);
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
    IRHCLogDataReader(@"%p, Call prepare", self);
    [self prepareSourceManager];
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
    IRHCLogDataReader(@"%p, Call close", self);
    [self.sourceManager close];
    [self.unit workingRelease];
    self.unit = nil;
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
    NSData *data = [self.sourceManager readDataOfLength:length];
    if (data.length > 0) {
        self->_readedLength += data.length;
        if (self.response.contentLength > 0) {
            self->_progress = (double)self.readedLength / (double)self.response.contentLength;
        }
    }
    IRHCLogDataReader(@"%p, Read data : %lld", self, (long long)data.length);
    if (self.sourceManager.isFinished) {
        IRHCLogDataReader(@"%p, Read data did finished", self);
        self->_finished = YES;
        [self close];
    }
    [self unlock];
    return data;
}

- (void)prepareSourceManager
{
    NSMutableArray<IRHCDataFileSource *> *fileSources = [NSMutableArray array];
    NSMutableArray<IRHCDataNetworkSource *> *networkSources = [NSMutableArray array];
    long long min = self.request.range.start;
    long long max = self.request.range.end;
    NSArray *unitItems = self.unit.unitItems;
    for (IRHCDataUnitItem *item in unitItems) {
        long long itemMin = item.offset;
        long long itemMax = item.offset + item.length - 1;
        if (itemMax < min || itemMin > max) {
            continue;
        }
        if (min > itemMin) {
            itemMin = min;
        }
        if (max < itemMax) {
            itemMax = max;
        }
        min = itemMax + 1;
        IRHCRange range = IRHCMakeRange(item.offset, item.offset + item.length - 1);
        IRHCRange readRange = IRHCMakeRange(itemMin - item.offset, itemMax - item.offset);
        IRHCDataFileSource *source = [[IRHCDataFileSource alloc] initWithPath:item.absolutePath range:range readRange:readRange];
        [fileSources addObject:source];
    }
    [fileSources sortUsingComparator:^NSComparisonResult(IRHCDataFileSource *obj1, IRHCDataFileSource *obj2) {
        if (obj1.range.start < obj2.range.start) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    long long offset = self.request.range.start;
    long long length = IRHCRangeIsFull(self.request.range) ? IRHCRangeGetLength(self.request.range) : (self.request.range.end - offset + 1);
    for (IRHCDataFileSource *obj in fileSources) {
        long long delta = obj.range.start + obj.readRange.start - offset;
        if (delta > 0) {
            IRHCRange range = IRHCMakeRange(offset, offset + delta - 1);
            IRHCDataRequest *request = [self.request newRequestWithRange:range];
            IRHCDataNetworkSource *source = [[IRHCDataNetworkSource alloc] initWithRequest:request];
            [networkSources addObject:source];
            offset += delta;
            length -= delta;
        }
        offset += IRHCRangeGetLength(obj.readRange);
        length -= IRHCRangeGetLength(obj.readRange);
    }
    if (length > 0) {
        IRHCRange range = IRHCMakeRange(offset, self.request.range.end);
        IRHCDataRequest *request = [self.request newRequestWithRange:range];
        IRHCDataNetworkSource *source = [[IRHCDataNetworkSource alloc] initWithRequest:request];
        [networkSources addObject:source];
    }
    NSMutableArray<id<IRHCDataSource>> *sources = [NSMutableArray array];
    [sources addObjectsFromArray:fileSources];
    [sources addObjectsFromArray:networkSources];
    self.sourceManager = [[IRHCDataSourceManager alloc] initWithSources:sources delegate:self delegateQueue:self.internalDelegateQueue];
    [self.sourceManager prepare];
}

- (void)ir_sourceManagerDidPrepare:(IRHCDataSourceManager *)sourceManager
{
    [self lock];
    [self callbackForPrepared];
    [self unlock];
}

- (void)ir_sourceManager:(IRHCDataSourceManager *)sourceManager didReceiveResponse:(IRHCDataResponse *)response
{
    [self lock];
    [self.unit updateResponseHeaders:response.headers totalLength:response.totalLength];
    [self callbackForPrepared];
    [self unlock];
}

- (void)ir_sourceManagerHasAvailableData:(IRHCDataSourceManager *)sourceManager
{
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(ir_readerHasAvailableData:)]) {
        IRHCLogDataReader(@"%p, Callback for has available data - Begin", self);
        [IRHCDataCallback callbackWithQueue:self.delegateQueue block:^{
            IRHCLogDataReader(@"%p, Callback for has available data - End", self);
            [self.delegate ir_readerHasAvailableData:self];
        }];
    }
    [self unlock];
}

- (void)ir_sourceManager:(IRHCDataSourceManager *)sourceManager didFailWithError:(NSError *)error
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
    [self close];
    [[IRHCLog log] addError:self.error forURL:self.request.URL];
    if ([self.delegate respondsToSelector:@selector(ir_reader:didFailWithError:)]) {
        IRHCLogDataReader(@"%p, Callback for failed - Begin\nError : %@", self, self.error);
        [IRHCDataCallback callbackWithQueue:self.delegateQueue block:^{
            IRHCLogDataReader(@"%p, Callback for failed - End", self);
            [self.delegate ir_reader:self didFailWithError:self.error];
        }];
    }
    [self unlock];
}

- (void)callbackForPrepared
{
    if (self.isClosed) {
        return;
    }
    if (self.isPrepared) {
        return;
    }
    if (self.sourceManager.isPrepared && self.unit.totalLength > 0) {
        long long totalLength = self.unit.totalLength;
        IRHCRange range = IRHCRangeWithEnsureLength(self.request.range, totalLength);
        NSDictionary *headers = IRHCRangeFillToResponseHeaders(range, self.unit.responseHeaders, totalLength);
        self->_response = [[IRHCDataResponse alloc] initWithURL:self.request.URL headers:headers];
        self->_prepared = YES;
        IRHCLogDataReader(@"%p, Reader did prepared\nResponse : %@", self, self.response);
        if ([self.delegate respondsToSelector:@selector(ir_readerDidPrepare:)]) {
            IRHCLogDataReader(@"%p, Callback for prepared - Begin", self);
            [IRHCDataCallback callbackWithQueue:self.delegateQueue block:^{
                IRHCLogDataReader(@"%p, Callback for prepared - End", self);
                [self.delegate ir_readerDidPrepare:self];
            }];
        }
    }
}

- (void)lock
{
    if (!self.coreLock) {
        self.coreLock = [[NSRecursiveLock alloc] init];
    }
    [self.coreLock lock];
}

- (void)unlock
{
    [self.coreLock unlock];
}

@end

