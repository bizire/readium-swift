//
//  IRHCDataFileSource.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@class IRHCDataFileSource;

@protocol IRHCDataFileSourceDelegate <NSObject>

- (void)ir_fileSourceDidPrepare:(IRHCDataFileSource *)fileSource;
- (void)ir_fileSource:(IRHCDataFileSource *)fileSource didFailWithError:(NSError *)error;

@end

@interface IRHCDataFileSource : NSObject <IRHCDataSource>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPath:(NSString *)path range:(IRHCRange)range readRange:(IRHCRange)readRange NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, readonly) IRHCRange readRange;

@property (nonatomic, weak, readonly) id<IRHCDataFileSourceDelegate> delegate;
@property (nonatomic, strong, readonly) dispatch_queue_t delegateQueue;

- (void)setDelegate:(id<IRHCDataFileSourceDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

@end

NS_ASSUME_NONNULL_END
