//
//  HTTPRedirectResponse.h
//  IRCocoaHTTPServer
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "HTTPResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTPRedirectResponse : NSObject <HTTPResponse>
{
    NSString *redirectPath;
}

- (id)initWithPath:(NSString *)redirectPath;

@end

NS_ASSUME_NONNULL_END
