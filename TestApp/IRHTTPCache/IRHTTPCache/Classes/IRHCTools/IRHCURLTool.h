//
//  IRHCURLTool.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRHCURLTool : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)tool;

@property (nonatomic, copy) NSURL * (^URLConverter)(NSURL *URL);

- (NSString *)keyWithURL:(NSURL *)URL;

- (NSString *)URLEncode:(NSString *)URLString;
- (NSString *)URLDecode:(NSString *)URLString;

- (NSDictionary<NSString *, NSString *> *)parseQuery:(NSString *)query;

@end


NS_ASSUME_NONNULL_END
