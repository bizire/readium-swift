//
//  IRHCDataResponse.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCRange.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRHCDataResponse : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSDictionary *headers;
@property (nonatomic, copy, readonly) NSString *contentType;
@property (nonatomic, copy, readonly) NSString *contentRangeString;
@property (nonatomic, readonly) IRHCRange contentRange;
@property (nonatomic, readonly) long long contentLength;
@property (nonatomic, readonly) long long totalLength;

@end

NS_ASSUME_NONNULL_END
