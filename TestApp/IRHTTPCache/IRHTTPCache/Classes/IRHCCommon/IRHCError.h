//
//  IRHCError.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IRHCErrorCode) {
    IRHCErrorCodeResponseUnavailable  = -192700,
    IRHCErrorCodeUnsupportContentType = -192701,
    IRHCErrorCodeNotEnoughDiskSpace   = -192702,
    IRHCErrorCodeException            = -192703,
};

@interface IRHCError : NSObject

+ (NSError *)errorForResponseUnavailable:(NSURL *)URL
                                 request:(NSURLRequest *)request
                                response:(NSURLResponse *)response;

+ (NSError *)errorForUnsupportContentType:(NSURL *)URL
                                  request:(NSURLRequest *)request
                                 response:(NSURLResponse *)response;

+ (NSError *)errorForNotEnoughDiskSpace:(long long)totlaContentLength
                                request:(long long)currentContentLength
                       totalCacheLength:(long long)totalCacheLength
                         maxCacheLength:(long long)maxCacheLength;

+ (NSError *)errorForException:(NSException *)exception;

@end

