//
//  IRHCHTTPServer.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/29.
//

#import "IRHCHTTPServer.h"
#import "IRHCHTTPConnection.h"
#import "IRHCHTTPHeader.h"
#import "IRHCURLTool.h"
#import "IRHCLog.h"
#import <UIKit/UIKit.h>

@interface IRHCHTTPServer ()

@property (nonatomic, strong) HTTPServer *server;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) BOOL wantsRunning;

@end

@implementation IRHCHTTPServer

+ (instancetype)server
{
    static IRHCHTTPServer *obj = nil;
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
        self.server = [[HTTPServer alloc] init];
        [self.server setConnectionClass:[IRHCHTTPConnection class]];
        [self.server setType:@"_http._tcp."];
        [self.server setPort:80];
        self.backgroundTask = UIBackgroundTaskInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(HTTPConnectionDidDie)
                                                     name:HTTPConnectionDidDieNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    IRHCLogDealloc(self);
    [self stopInternal];
}

- (BOOL)isRunning
{
    return self.server.isRunning;
}

- (BOOL)start:(NSError **)error
{
    self.wantsRunning = YES;
    return [self startInternal:error];
}

- (void)stop
{
    self.wantsRunning = NO;
    [self stopInternal];
}

- (NSURL *)URLWithOriginalURL:(NSURL *)URL
{
    if (!URL || URL.isFileURL || URL.absoluteString.length == 0) {
        return URL;
    }
    if (!self.isRunning) {
        return URL;
    }
    NSString *original = [[IRHCURLTool tool] URLEncode:URL.absoluteString];
    NSString *server = [NSString stringWithFormat:@"http://localhost:%d/", self.server.listeningPort];
    NSString *extension = URL.pathExtension ? [NSString stringWithFormat:@".%@", URL.pathExtension] : @"";
    NSString *URLString = [NSString stringWithFormat:@"%@request%@?url=%@", server, extension, original];
    URL = [NSURL URLWithString:URLString];
    IRHCLogHTTPServer(@"%p, Return URL\nURL : %@", self, URL);
    return URL;
}

#pragma mark - Internal

- (BOOL)startInternal:(NSError **)error
{
    BOOL ret = [self.server start:error];
    if (ret) {
        IRHCLogHTTPServer(@"%p, Start server success", self);
    } else {
        IRHCLogHTTPServer(@"%p, Start server failed", self);
    }
    return ret;
}

- (void)stopInternal
{
    [self.server stop];
}

#pragma mark - Background Task

- (void)applicationDidEnterBackground
{
    if (self.server.numberOfHTTPConnections > 0) {
        IRHCLogHTTPServer(@"%p, enter background", self);
        [self beginBackgroundTask];
    } else {
        IRHCLogHTTPServer(@"%p, enter background and stop server", self);
        [self stopInternal];
    }
}

- (void)applicationWillEnterForeground
{
    IRHCLogHTTPServer(@"%p, enter foreground", self);
    if (self.backgroundTask == UIBackgroundTaskInvalid && self.wantsRunning) {
        IRHCLogHTTPServer(@"%p, restart server", self);
        [self startInternal:nil];
    }
    [self endBackgroundTask];
}

- (void)HTTPConnectionDidDie
{
    IRHCLogHTTPServer(@"%p, connection did die", self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground &&
            self.server.numberOfHTTPConnections == 0) {
            IRHCLogHTTPServer(@"%p, server idle", self);
            [self endBackgroundTask];
            [self stopInternal];
        }
    });
}

- (void)beginBackgroundTask
{
    IRHCLogHTTPServer(@"%p, begin background task", self);
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        IRHCLogHTTPServer(@"%p, background task expiration", self);
        [self endBackgroundTask];
        [self stopInternal];
    }];
}

- (void)endBackgroundTask
{
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        IRHCLogHTTPServer(@"%p, end background task", self);
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

@end

