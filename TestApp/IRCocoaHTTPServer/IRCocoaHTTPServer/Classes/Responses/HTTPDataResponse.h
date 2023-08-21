//
//  HTTPDataResponse.h
//  IRCocoaHTTPServer
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "HTTPResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPDataResponse : NSObject <HTTPResponse>
{
    NSUInteger offset;
    NSData *data;
}

- (id)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
