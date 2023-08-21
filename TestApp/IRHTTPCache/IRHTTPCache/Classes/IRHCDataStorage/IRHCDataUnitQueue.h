//
//  IRHCDataUnitQueue.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>
#import "IRHCDataUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRHCDataUnitQueue : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPath:(NSString *)path NS_DESIGNATED_INITIALIZER;

- (NSArray<IRHCDataUnit *> *)allUnits;
- (IRHCDataUnit *)unitWithKey:(NSString *)key;

- (void)putUnit:(IRHCDataUnit *)unit;
- (void)popUnit:(IRHCDataUnit *)unit;

- (void)archive;

@end


NS_ASSUME_NONNULL_END
