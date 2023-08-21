//
//  IRHCDataCallback.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IRHCDataCallback : NSObject

+ (void)callbackWithQueue:(dispatch_queue_t)queue block:(void (^)(void))block;      // Default is async.
+ (void)callbackWithQueue:(dispatch_queue_t)queue block:(void (^)(void))block async:(BOOL)async;

@end

NS_ASSUME_NONNULL_END
