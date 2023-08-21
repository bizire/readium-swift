//
//  IRHCDataFileSource.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataFileSource.h"
#import "IRHCDataCallback.h"
#import "IRHCError.h"
#import "IRHCLog.h"

@interface IRHCDataFileSource () <NSLocking>

@property (nonatomic, strong) NSLock *coreLock;
@property (nonatomic, strong) NSFileHandle *readingHandle;

@end

@implementation IRHCDataFileSource

@synthesize error = _error;
@synthesize range = _range;
@synthesize closed = _closed;
@synthesize prepared = _prepared;
@synthesize finished = _finished;
@synthesize readedLength = _readedLength;

- (instancetype)initWithPath:(NSString *)path range:(IRHCRange)range readRange:(IRHCRange)readRange
{
    if (self = [super init])
    {
        IRHCLogAlloc(self);
        self->_path = path;
        self->_range = range;
        self->_readRange = readRange;
        IRHCLogDataFileSource(@"%p, Create file source\npath : %@\nrange : %@\nreadRange : %@", self, path, IRHCStringFromRange(range), IRHCStringFromRange(readRange));
    }
    return self;
}

- (void)dealloc
{
    IRHCLogDealloc(self);
}

- (void)prepare
{
    [self lock];
    if (self.isPrepared) {
        [self unlock];
        return;
    }
    IRHCLogDataFileSource(@"%p, Call prepare", self);
    self.readingHandle = [NSFileHandle fileHandleForReadingAtPath:self.path];
    @try {
        [self.readingHandle seekToFileOffset:self.readRange.start];
        self->_prepared = YES;
        if ([self.delegate respondsToSelector:@selector(ir_fileSourceDidPrepare:)]) {
            IRHCLogDataFileSource(@"%p, Callback for prepared - Begin", self);
            [IRHCDataCallback callbackWithQueue:self.delegateQueue block:^{
                IRHCLogDataFileSource(@"%p, Callback for prepared - End", self);
                [self.delegate ir_fileSourceDidPrepare:self];
            }];
        }
    } @catch (NSException *exception) {
        IRHCLogDataFileSource(@"%p, Seek file exception\nname : %@\nreason : %@\nuserInfo : %@", self, exception.name, exception.reason, exception.userInfo);
        NSError *error = [IRHCError errorForException:exception];
        [self callbackForFailed:error];
    }
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
    IRHCLogDataFileSource(@"%p, Call close", self);
    [self destoryReadingHandle];
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
    NSData *data = nil;
    @try {
        long long readLength = IRHCRangeGetLength(self.readRange);
        length = (NSUInteger)MIN(readLength - self.readedLength, length);
        data = [self.readingHandle readDataOfLength:length];
        self->_readedLength += data.length;
        if (data.length > 0) {
            IRHCLogDataFileSource(@"%p, Read data : %lld, %lld, %lld", self, (long long)data.length, self.readedLength, readLength);
        }
        if (self.readedLength >= readLength) {
            IRHCLogDataFileSource(@"%p, Read data did finished", self);
            [self destoryReadingHandle];
            self->_finished = YES;
        }
    } @catch (NSException *exception) {
        IRHCLogDataFileSource(@"%p, Read exception\nname : %@\nreason : %@\nuserInfo : %@", self, exception.name, exception.reason, exception.userInfo);
        NSError *error = [IRHCError errorForException:exception];
        [self callbackForFailed:error];
    }
    [self unlock];
    return data;
}

- (void)destoryReadingHandle
{
    if (self.readingHandle) {
        @try {
            [self.readingHandle closeFile];
        } @catch (NSException *exception) {
            IRHCLogDataFileSource(@"%p, Close exception\nname : %@\nreason : %@\nuserInfo : %@", self, exception.name, exception.reason, exception.userInfo);
        }
        self.readingHandle = nil;
    }
}

- (void)callbackForFailed:(NSError *)error
{
    if (!error) {
        return;
    }
    if (self.error) {
        return;
    }
    self->_error = error;
    if ([self.delegate respondsToSelector:@selector(ir_fileSource:didFailWithError:)]) {
        IRHCLogDataFileSource(@"%p, Callback for prepared - Begin", self);
        [IRHCDataCallback callbackWithQueue:self.delegateQueue block:^{
            IRHCLogDataFileSource(@"%p, Callback for prepared - End", self);
            [self.delegate ir_fileSource:self didFailWithError:self.error];
        }];
    }
}

- (void)setDelegate:(id <IRHCDataFileSourceDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    self->_delegate = delegate;
    self->_delegateQueue = delegateQueue;
}

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

