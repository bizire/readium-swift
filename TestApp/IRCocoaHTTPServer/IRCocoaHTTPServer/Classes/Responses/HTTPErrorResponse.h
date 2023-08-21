//
//  HTTPErrorResponse.h
//  IRCocoaHTTPServer
//
//  Created by irons on 2021/3/26.
//

#import "HTTPResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPErrorResponse : NSObject <HTTPResponse> {
    NSInteger _status;
}

- (id)initWithErrorCode:(int)httpErrorCode;

@end

NS_ASSUME_NONNULL_END
