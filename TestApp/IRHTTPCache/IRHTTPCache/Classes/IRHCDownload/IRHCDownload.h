//
//  IRHCDownload.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCDataResponse.h"
#import "IRHCDataRequest.h"
#import "IRHCMacro.h"

IRHTTPCACHE_EXTERN NSString * const IRHCContentTypeVideo;
IRHTTPCACHE_EXTERN NSString * const IRHCContentTypeAudio;
IRHTTPCACHE_EXTERN NSString * const IRHCContentTypeApplicationMPEG4;
IRHTTPCACHE_EXTERN NSString * const IRHCContentTypeApplicationOctetStream;
IRHTTPCACHE_EXTERN NSString * const IRHCContentTypeBinaryOctetStream;

@class IRHCDownload;

NS_ASSUME_NONNULL_BEGIN

@protocol IRHCDownloadDelegate <NSObject>

- (void)ir_download:(IRHCDownload *)download didCompleteWithError:(NSError *)error;
- (void)ir_download:(IRHCDownload *)download didReceiveResponse:(IRHCDataResponse *)response;
- (void)ir_download:(IRHCDownload *)download didReceiveData:(NSData *)data;

@end

@interface IRHCDownload : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)download;

@property (nonatomic) NSTimeInterval timeoutInterval;

/**
 *  Header Fields
 */
@property (nonatomic, copy) NSArray<NSString *> *whitelistHeaderKeys;
@property (nonatomic, copy) NSDictionary<NSString *, NSString *> *additionalHeaders;

/**
 *  Content-Type
 */
@property (nonatomic, copy) NSArray<NSString *> *acceptableContentTypes;
@property (nonatomic, copy) BOOL (^unacceptableContentTypeDisposer)(NSURL *URL, NSString *contentType);

- (NSURLSessionTask *)downloadWithRequest:(IRHCDataRequest *)request delegate:(id<IRHCDownloadDelegate>)delegate;

@end


NS_ASSUME_NONNULL_END
