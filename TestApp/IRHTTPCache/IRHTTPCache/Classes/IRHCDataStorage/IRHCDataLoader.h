//
//  IRHCDataLoader.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

@class IRHCDataLoader;
@class IRHCDataRequest;
@class IRHCDataResponse;

NS_ASSUME_NONNULL_BEGIN

@protocol IRHCDataLoaderDelegate <NSObject>

- (void)ir_loaderDidFinish:(IRHCDataLoader *)loader;
- (void)ir_loader:(IRHCDataLoader *)loader didFailWithError:(NSError *)error;
- (void)ir_loader:(IRHCDataLoader *)loader didChangeProgress:(double)progress;

@end

@interface IRHCDataLoader : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, weak) id <IRHCDataLoaderDelegate> delegate;
@property (nonatomic, strong) id object;

@property (nonatomic, strong, readonly) IRHCDataRequest *request;
@property (nonatomic, strong, readonly) IRHCDataResponse *response;

@property (nonatomic, copy, readonly) NSError *error;

@property (nonatomic, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, readonly, getter=isClosed) BOOL closed;

@property (nonatomic, readonly) long long loadedLength;
@property (nonatomic, readonly) double progress;

- (void)prepare;
- (void)close;

@end


NS_ASSUME_NONNULL_END
