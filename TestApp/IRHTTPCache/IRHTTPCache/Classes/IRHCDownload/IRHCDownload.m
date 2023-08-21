//
//  IRHCDownload.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDownload.h"
#import "IRHCData+Internal.h"
#import "IRHCDataUnitPool.h"
#import "IRHCDataStorage.h"
#import "IRHCError.h"
#import "IRHCLog.h"

#import <UIKit/UIKit.h>

NSString * const IRHCContentTypeVideo                  = @"video/";
NSString * const IRHCContentTypeAudio                  = @"audio/";
NSString * const IRHCContentTypeApplicationMPEG4       = @"application/mp4";
NSString * const IRHCContentTypeApplicationOctetStream = @"application/octet-stream";
NSString * const IRHCContentTypeBinaryOctetStream      = @"binary/octet-stream";

@interface IRHCDownload () <NSURLSessionDataDelegate, NSLocking>

@property (nonatomic, strong) NSLock *coreLock;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *sessionDelegateQueue;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, NSError *> *errorDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, IRHCDataRequest *> *requestDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, id<IRHCDownloadDelegate>> *delegateDictionary;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation IRHCDownload

+ (instancetype)download
{
    static IRHCDownload *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    if (self = [super init]) {
        IRHCLogAlloc(self);
        self.timeoutInterval = 30.0f;
        self.backgroundTask = UIBackgroundTaskInvalid;
        self.errorDictionary = [NSMutableDictionary dictionary];
        self.requestDictionary = [NSMutableDictionary dictionary];
        self.delegateDictionary = [NSMutableDictionary dictionary];
        self.sessionDelegateQueue = [[NSOperationQueue alloc] init];
        self.sessionDelegateQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.sessionConfiguration.timeoutIntervalForRequest = self.timeoutInterval;
        self.sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration
                                                     delegate:self
                                                delegateQueue:self.sessionDelegateQueue];
        self.acceptableContentTypes = @[IRHCContentTypeVideo,
                                        IRHCContentTypeAudio,
                                        IRHCContentTypeApplicationMPEG4,
                                        IRHCContentTypeApplicationOctetStream,
                                        IRHCContentTypeBinaryOctetStream];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc
{
    IRHCLogDealloc(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray<NSString *> *)availableHeaderKeys
{
    static NSArray<NSString *> *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = @[@"User-Agent",
                @"Connection",
                @"Accept",
                @"Accept-Encoding",
                @"Accept-Language",
                @"Range"];
    });
    return obj;
}

- (NSURLSessionTask *)downloadWithRequest:(IRHCDataRequest *)request delegate:(id<IRHCDownloadDelegate>)delegate
{
    [self lock];
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:request.URL];
    mRequest.timeoutInterval = self.timeoutInterval;
    mRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [request.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        if ([self.availableHeaderKeys containsObject:key] ||
            [self.whitelistHeaderKeys containsObject:key]) {
            [mRequest setValue:obj forHTTPHeaderField:key];
        }
    }];
    [self.additionalHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [mRequest setValue:obj forHTTPHeaderField:key];
    }];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:mRequest];
    [self.requestDictionary setObject:request forKey:task];
    [self.delegateDictionary setObject:delegate forKey:task];
    task.priority = 1.0;
    [task resume];
    IRHCLogDownload(@"%p, Add Request\nrequest : %@\nURL : %@\nheaders : %@\nHTTPRequest headers : %@\nCount : %d", self, request, request.URL, request.headers, mRequest.allHTTPHeaderFields, (int)self.delegateDictionary.count);
    [self unlock];
    return task;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self lock];
    IRHCLogDownload(@"%p, Complete\nError : %@", self, error);
    if ([self.errorDictionary objectForKey:task]) {
        error = [self.errorDictionary objectForKey:task];
    }
    id<IRHCDownloadDelegate> delegate = [self.delegateDictionary objectForKey:task];
    [delegate ir_download:self didCompleteWithError:error];
    [self.delegateDictionary removeObjectForKey:task];
    [self.requestDictionary removeObjectForKey:task];
    [self.errorDictionary removeObjectForKey:task];
    if (self.delegateDictionary.count <= 0) {
        [self endBackgroundTaskDelay];
    }
    [self unlock];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self lock];
    IRHCDataRequest *dataRequest = [self.requestDictionary objectForKey:task];
    IRHCDataResponse *dataResponse = [[IRHCDataResponse alloc] initWithURL:dataRequest.URL headers:response.allHeaderFields];
    IRHCLogDownload(@"%p, Receive response\nrequest : %@\nresponse : %@\nHTTPResponse : %@", self, dataRequest, dataResponse, response.allHeaderFields);
    NSError *error = nil;
    if (!error) {
        if (response.statusCode > 400) {
            error = [IRHCError errorForResponseUnavailable:task.currentRequest.URL
                                                    request:task.currentRequest
                                                   response:task.response];
        }
    }
    if (!error) {
        BOOL vaild = NO;
        if (dataResponse.contentType.length > 0) {
            for (NSString *obj in self.acceptableContentTypes) {
                if ([[dataResponse.contentType lowercaseString] containsString:[obj lowercaseString]]) {
                    vaild = YES;
                }
            }
            if (!vaild && self.unacceptableContentTypeDisposer) {
                vaild = self.unacceptableContentTypeDisposer(dataRequest.URL, dataResponse.contentType);
            }
        }
        if (!vaild) {
            error = [IRHCError errorForUnsupportContentType:task.currentRequest.URL
                                                     request:task.currentRequest
                                                    response:task.response];
        }
    }
    if (!error) {
        if (dataResponse.contentLength <= 0 ||
            (!IRHCRangeIsFull(dataRequest.range) &&
             (dataResponse.contentLength != IRHCRangeGetLength(dataRequest.range)))) {
                error = [IRHCError errorForUnsupportContentType:task.currentRequest.URL
                                                         request:task.currentRequest
                                                        response:task.response];
            }
    }
    if (!error) {
        long long (^getDeletionLength)(long long) = ^(long long desireLength){
            return desireLength + [IRHCDataStorage storage].totalCacheLength - [IRHCDataStorage storage].maxCacheLength;
        };
        long long length = getDeletionLength(dataResponse.contentLength);
        if (length > 0) {
            [[IRHCDataUnitPool pool] deleteUnitsWithLength:length];
            length = getDeletionLength(dataResponse.contentLength);
            if (length > 0) {
                error = [IRHCError errorForNotEnoughDiskSpace:dataResponse.totalLength
                                                       request:dataResponse.contentLength
                                              totalCacheLength:[IRHCDataStorage storage].totalCacheLength
                                                maxCacheLength:[IRHCDataStorage storage].maxCacheLength];
            }
        }
    }
    if (error) {
        IRHCLogDownload(@"%p, Invaild response\nError : %@", self, error);
        [self.errorDictionary setObject:error forKey:task];
        completionHandler(NSURLSessionResponseCancel);
    } else {
        id<IRHCDownloadDelegate> delegate = [self.delegateDictionary objectForKey:task];
        [delegate ir_download:self didReceiveResponse:dataResponse];
        completionHandler(NSURLSessionResponseAllow);
    }
    [self unlock];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    [self lock];
    IRHCLogDownload(@"%p, Perform HTTP redirection\nresponse : %@\nrequest : %@", self, response, request);
    completionHandler(request);
    [self unlock];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self lock];
    IRHCLogDownload(@"%p, Receive data - Begin\nLength : %lld\nURL : %@", self, (long long)data.length, dataTask.originalRequest.URL.absoluteString);
    id<IRHCDownloadDelegate> delegate = [self.delegateDictionary objectForKey:dataTask];
    [delegate ir_download:self didReceiveData:data];
    IRHCLogDownload(@"%p, Receive data - End\nLength : %lld\nURL : %@", self, (long long)data.length, dataTask.originalRequest.URL.absoluteString);
    [self unlock];
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

#pragma mark - Background Task

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self lock];
    if (self.delegateDictionary.count > 0) {
        [self beginBackgroundTask];
    }
    [self unlock];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self endBackgroundTask];
}

- (void)beginBackgroundTask
{
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
}

- (void)endBackgroundTask
{
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)endBackgroundTaskDelay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self lock];
        if (self.delegateDictionary.count <= 0) {
            [self endBackgroundTask];
        }
        [self unlock];
    });
}

@end

