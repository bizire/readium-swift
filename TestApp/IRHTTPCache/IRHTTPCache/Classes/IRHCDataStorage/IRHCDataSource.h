//
//  IRHCDataSource.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCRange.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IRHCDataSource <NSObject>

@property (nonatomic, copy, readonly) NSError *error;

@property (nonatomic, readonly, getter=isPrepared) BOOL prepared;
@property (nonatomic, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, readonly, getter=isClosed) BOOL closed;

@property (nonatomic, readonly) IRHCRange range;
@property (nonatomic, readonly) long long readedLength;

- (void)prepare;
- (void)close;

- (NSData *)readDataOfLength:(NSUInteger)length;

@end

NS_ASSUME_NONNULL_END
