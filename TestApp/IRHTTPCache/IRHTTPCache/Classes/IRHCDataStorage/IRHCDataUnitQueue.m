//
//  IRHCDataUnitQueue.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCDataUnitQueue.h"
#import "IRHCLog.h"

@interface IRHCDataUnitQueue ()

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSMutableArray<IRHCDataUnit *> *unitArray;

@end

@implementation IRHCDataUnitQueue

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        self.path = path;
        NSMutableArray *unitArray = nil;
        @try {
            unitArray = [NSKeyedUnarchiver unarchiveObjectWithFile:self.path];
        } @catch (NSException *exception) {
            IRHCLogDataUnitQueue(@"%p, Init exception\nname : %@\breason : %@\nuserInfo : %@", self, exception.name, exception.reason, exception.userInfo);
        }
        self.unitArray = [NSMutableArray array];
        for (IRHCDataUnit *obj in unitArray) {
            if (obj.error) {
                [obj deleteFiles];
            } else {
                [self.unitArray addObject:obj];
            }
        }
    }
    return self;
}

- (NSArray<IRHCDataUnit *> *)allUnits
{
    if (self.unitArray.count <= 0) {
        return nil;
    }
    return [self.unitArray copy];
}

- (IRHCDataUnit *)unitWithKey:(NSString *)key
{
    if (key.length <= 0) {
        return nil;
    }
    IRHCDataUnit *unit = nil;
    for (IRHCDataUnit *obj in self.unitArray) {
        if ([obj.key isEqualToString:key]) {
            unit = obj;
            break;
        }
    }
    return unit;
}

- (void)putUnit:(IRHCDataUnit *)unit
{
    if (!unit) {
        return;
    }
    if (![self.unitArray containsObject:unit]) {
        [self.unitArray addObject:unit];
    }
}

- (void)popUnit:(IRHCDataUnit *)unit
{
    if (!unit) {
        return;
    }
    if ([self.unitArray containsObject:unit]) {
        [self.unitArray removeObject:unit];
    }
}

- (void)archive
{
    IRHCLogDataUnitQueue(@"%p, Archive - Begin, %ld", self, (long)self.unitArray.count);
    [NSKeyedArchiver archiveRootObject:self.unitArray toFile:self.path];
    IRHCLogDataUnitQueue(@"%p, Archive - End  , %ld", self, (long)self.unitArray.count);
}

@end

