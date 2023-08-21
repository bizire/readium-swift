//
//  IRHCRange.h
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct IRHCRange {
    long long start;
    long long end;
} IRHCRange;

static const long long IRHCNotFound = LONG_LONG_MAX;

BOOL IRHCRangeIsFull(IRHCRange range);
BOOL IRHCRangeIsVaild(IRHCRange range);
BOOL IRHCRangeIsInvaild(IRHCRange range);
BOOL IRHCEqualRanges(IRHCRange range1, IRHCRange range2);
long long IRHCRangeGetLength(IRHCRange range);
NSString * IRHCStringFromRange(IRHCRange range);
NSDictionary * IRHCRangeFillToRequestHeaders(IRHCRange range, NSDictionary *eaders);
NSDictionary * IRHCRangeFillToRequestHeadersIfNeeded(IRHCRange range, NSDictionary *headers);
NSDictionary * IRHCRangeFillToResponseHeaders(IRHCRange range, NSDictionary *headers, long long totalLength);

IRHCRange IRHCMakeRange(long long start, long long end);
IRHCRange IRHCRangeZero(void);
IRHCRange IRHCRangeFull(void);
IRHCRange IRHCRangeInvaild(void);
IRHCRange IRHCRangeWithSeparateValue(NSString *value);
IRHCRange IRHCRangeWithRequestHeaderValue(NSString *value);
IRHCRange IRHCRangeWithResponseHeaderValue(NSString *value, long long *totalLength);
IRHCRange IRHCRangeWithEnsureLength(IRHCRange range, long long ensureLength);


NS_ASSUME_NONNULL_END
