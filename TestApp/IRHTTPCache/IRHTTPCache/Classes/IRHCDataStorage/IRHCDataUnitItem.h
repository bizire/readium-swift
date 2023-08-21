//
//  IRHCDataUnitItem.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRHCDataUnitItem : NSObject <NSCopying, NSCoding, NSLocking>

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithPath:(NSString *)path;
- (instancetype)initWithPath:(NSString *)path offset:(uint64_t)offset;

@property (nonatomic, copy, readonly) NSString *relativePath;
@property (nonatomic, copy, readonly) NSString *absolutePath;
@property (nonatomic, readonly) NSTimeInterval createTimeInterval;
@property (nonatomic, readonly) long long offset;
@property (nonatomic, readonly) long long length;

- (void)updateLength:(long long)length;

@end


NS_ASSUME_NONNULL_END
