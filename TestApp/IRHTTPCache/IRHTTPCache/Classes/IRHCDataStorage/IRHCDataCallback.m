//
//  IRHCDataCallback.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataCallback.h"

@implementation IRHCDataCallback

+ (void)callbackWithQueue:(dispatch_queue_t)queue block:(void (^)(void))block
{
    [self callbackWithQueue:queue block:block async:YES];
}

+ (void)callbackWithQueue:(dispatch_queue_t)queue block:(void (^)(void))block async:(BOOL)async
{
    if (!queue) {
        return;
    }
    if (!block) {
        return;
    }
    if (async) {
        dispatch_async(queue, ^{
            if (block) {
                block();
            }
        });
    } else {
        dispatch_sync(queue, ^{
            if (block) {
                block();
            }
        });
    }
}

@end

