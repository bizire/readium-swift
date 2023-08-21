//
//  IRHCDataNetworkSource.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCDataSource.h"
#import "IRHCDataRequest.h"
#import "IRHCDataResponse.h"

NS_ASSUME_NONNULL_BEGIN

@class IRHCDataNetworkSource;

@protocol IRHCDataNetworkSourceDelegate <NSObject>

- (void)ir_networkSourceDidPrepare:(IRHCDataNetworkSource *)networkSource;
- (void)ir_networkSourceHasAvailableData:(IRHCDataNetworkSource *)networkSource;
- (void)ir_networkSourceDidFinisheDownload:(IRHCDataNetworkSource *)networkSource;
- (void)ir_networkSource:(IRHCDataNetworkSource *)networkSource didFailWithError:(NSError *)error;

@end

@interface IRHCDataNetworkSource : NSObject <IRHCDataSource>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithRequest:(IRHCDataRequest *)reqeust NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) IRHCDataRequest *request;
@property (nonatomic, strong, readonly) IRHCDataResponse *response;

@property (nonatomic, weak, readonly) id<IRHCDataNetworkSourceDelegate> delegate;
@property (nonatomic, strong, readonly) dispatch_queue_t delegateQueue;

- (void)setDelegate:(id<IRHCDataNetworkSourceDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

@end

NS_ASSUME_NONNULL_END
