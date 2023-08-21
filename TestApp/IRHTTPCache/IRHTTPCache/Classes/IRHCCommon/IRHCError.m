//
//  IRHCError.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCError.h"

NSString * const IRHCErrorUserInfoKeyURL      = @"IRHCErrorUserInfoKeyURL";
NSString * const IRHCErrorUserInfoKeyRequest  = @"IRHCErrorUserInfoKeyRequest";
NSString * const IRHCErrorUserInfoKeyResponse = @"IRHCErrorUserInfoKeyResponse";

@implementation IRHCError

+ (NSError *)errorForResponseUnavailable:(NSURL *)URL
                                 request:(NSURLRequest *)request
                                response:(NSURLResponse *)response
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (URL) {
        [userInfo setObject:URL forKey:IRHCErrorUserInfoKeyURL];
    }
    if (request) {
        [userInfo setObject:request forKey:IRHCErrorUserInfoKeyRequest];
    }
    if (response) {
        [userInfo setObject:response forKey:IRHCErrorUserInfoKeyResponse];
    }
    NSError *error = [NSError errorWithDomain:@"IRHTTPCache error"
                                         code:IRHCErrorCodeResponseUnavailable
                                     userInfo:userInfo];
    return error;
}

+ (NSError *)errorForUnsupportContentType:(NSURL *)URL
                                  request:(NSURLRequest *)request
                                 response:(NSURLResponse *)response
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if (URL) {
        [userInfo setObject:URL forKey:IRHCErrorUserInfoKeyURL];
    }
    if (request) {
        [userInfo setObject:request forKey:IRHCErrorUserInfoKeyRequest];
    }
    if (response) {
        [userInfo setObject:response forKey:IRHCErrorUserInfoKeyResponse];
    }
    NSError *error = [NSError errorWithDomain:@"IRHTTPCache error"
                                         code:IRHCErrorCodeUnsupportContentType
                                     userInfo:userInfo];
    return error;
}

+ (NSError *)errorForNotEnoughDiskSpace:(long long)totlaContentLength
                                request:(long long)currentContentLength
                       totalCacheLength:(long long)totalCacheLength
                         maxCacheLength:(long long)maxCacheLength
{
    NSError *error = [NSError errorWithDomain:@"IRHTTPCache error"
                                         code:IRHCErrorCodeNotEnoughDiskSpace
                                     userInfo:@{@"totlaContentLength" : @(totlaContentLength),
                                                @"currentContentLength" : @(currentContentLength),
                                                @"totalCacheLength" : @(totalCacheLength),
                                                @"maxCacheLength" : @(maxCacheLength)}];
    return error;
}

+ (NSError *)errorForException:(NSException *)exception
{
    NSError *error = [NSError errorWithDomain:@"IRHTTPCache error"
                                        code:IRHCErrorCodeException
                                    userInfo:exception.userInfo];
    return error;
}


@end
