//
//  IRHCHTTPResponse.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/29.
//

#import <Foundation/Foundation.h>
#import "IRHCHTTPHeader.h"

NS_ASSUME_NONNULL_BEGIN

@class IRHCHTTPConnection;
@class IRHCDataRequest;

@interface IRHCHTTPResponse : NSObject <HTTPResponse>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithConnection:(IRHCHTTPConnection *)connection dataRequest:(IRHCDataRequest *)dataRequest NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
