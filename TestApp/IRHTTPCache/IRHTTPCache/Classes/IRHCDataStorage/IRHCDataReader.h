//
//  IRHCDataReader.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IRHCDataReader;
@class IRHCDataRequest;
@class IRHCDataResponse;

@protocol IRHCDataReaderDelegate <NSObject>

- (void)ir_readerDidPrepare:(IRHCDataReader *)reader;
- (void)ir_readerHasAvailableData:(IRHCDataReader *)reader;
- (void)ir_reader:(IRHCDataReader *)reader didFailWithError:(NSError *)error;

@end

@interface IRHCDataReader : NSObject <NSLocking>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, weak) id <IRHCDataReaderDelegate> delegate;
@property (nonatomic, strong) id object;

@property (nonatomic, strong, readonly) IRHCDataRequest *request;
@property (nonatomic, strong, readonly) IRHCDataResponse *response;

@property (nonatomic, copy, readonly) NSError *error;

@property (nonatomic, readonly, getter=isPrepared) BOOL prepared;
@property (nonatomic, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, readonly, getter=isClosed) BOOL closed;

@property (nonatomic, readonly) long long readedLength;
@property (nonatomic, readonly) double progress;

- (void)prepare;
- (void)close;

- (NSData *)readDataOfLength:(NSUInteger)length;

@end


NS_ASSUME_NONNULL_END
