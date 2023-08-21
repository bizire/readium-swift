//
//  DDNumber.h
//  IRCocoaHTTPServer
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (DDNumber)

+ (BOOL)parseString:(NSString *)str intoSInt64:(SInt64 *)pNum;
+ (BOOL)parseString:(NSString *)str intoUInt64:(UInt64 *)pNum;

+ (BOOL)parseString:(NSString *)str intoNSInteger:(NSInteger *)pNum;
+ (BOOL)parseString:(NSString *)str intoNSUInteger:(NSUInteger *)pNum;

@end

NS_ASSUME_NONNULL_END
