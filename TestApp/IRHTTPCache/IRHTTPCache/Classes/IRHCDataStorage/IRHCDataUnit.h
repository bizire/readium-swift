//
//  IRHCDataUnit.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCDataUnitItem.h"

NS_ASSUME_NONNULL_BEGIN

@class IRHCDataUnit;

@protocol IRHCDataUnitDelegate <NSObject>

- (void)ir_unitDidChangeMetadata:(IRHCDataUnit *)unit;

@end

@interface IRHCDataUnit : NSObject <NSCoding, NSLocking>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithURL:(NSURL *)URL;

@property (nonatomic, copy, readonly) NSError *error;

@property (nonatomic, copy, readonly) NSURL *URL;
@property (nonatomic, copy, readonly) NSURL *completeURL;
@property (nonatomic, copy, readonly) NSString *key;       // Unique Identifier.
@property (nonatomic, copy, readonly) NSDictionary *responseHeaders;
@property (nonatomic, readonly) NSTimeInterval createTimeInterval;
@property (nonatomic, readonly) NSTimeInterval lastItemCreateInterval;
@property (nonatomic, readonly) long long totalLength;
@property (nonatomic, readonly) long long cacheLength;
@property (nonatomic, readonly) long long validLength;

/**
 *  Unit Item
 */
- (NSArray<IRHCDataUnitItem *> *)unitItems;
- (void)insertUnitItem:(IRHCDataUnitItem *)unitItem;

/**
 *  Info Sync
 */
- (void)updateResponseHeaders:(NSDictionary *)responseHeaders totalLength:(long long)totalLength;

/**
 *  Working
 */
@property (nonatomic, readonly) NSInteger workingCount;

- (void)workingRetain;
- (void)workingRelease;

/**
 *  File Control
 */
@property (nonatomic, weak) id <IRHCDataUnitDelegate> delegate;

- (void)deleteFiles;

@end


NS_ASSUME_NONNULL_END
