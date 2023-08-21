//
//  IRHCHTTPServer.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRHCHTTPServer : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)server;

@property (nonatomic, readonly, getter=isRunning) BOOL running;

- (BOOL)start:(NSError **)error;
- (void)stop;

- (NSURL *)URLWithOriginalURL:(NSURL *)URL;

@end


NS_ASSUME_NONNULL_END
