//
//  IRHCDataRequest.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCRange.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRHCDataRequest : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSURL *)URL headers:(NSDictionary *)headers NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSDictionary *headers;
@property (nonatomic, readonly) IRHCRange range;

@end


NS_ASSUME_NONNULL_END
