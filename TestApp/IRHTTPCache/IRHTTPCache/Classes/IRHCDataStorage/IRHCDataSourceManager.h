//
//  IRHCDataSourceManager.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCDataNetworkSource.h"
#import "IRHCDataFileSource.h"

NS_ASSUME_NONNULL_BEGIN

@class IRHCDataSourceManager;

@protocol IRHCDataSourceManagerDelegate <NSObject>

- (void)ir_sourceManagerDidPrepare:(IRHCDataSourceManager *)sourceManager;
- (void)ir_sourceManagerHasAvailableData:(IRHCDataSourceManager *)sourceManager;
- (void)ir_sourceManager:(IRHCDataSourceManager *)sourceManager didFailWithError:(NSError *)error;
- (void)ir_sourceManager:(IRHCDataSourceManager *)sourceManager didReceiveResponse:(IRHCDataResponse *)response;

@end

@interface IRHCDataSourceManager : NSObject <IRHCDataSource>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSources:(NSArray<id<IRHCDataSource>> *)sources
                       delegate:(id <IRHCDataSourceManagerDelegate>)delegate
                  delegateQueue:(dispatch_queue_t)delegateQueue NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak, readonly) id <IRHCDataSourceManagerDelegate> delegate;
@property (nonatomic, strong, readonly) dispatch_queue_t delegateQueue;

@end


NS_ASSUME_NONNULL_END
