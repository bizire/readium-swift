//
//  IRHCRange.m
//  IRHTTPCache
//
//  Created by irons on 2021/3/26.
//

#import "IRHCRange.h"

BOOL IRHCRangeIsFull(IRHCRange range)
{
    return IRHCEqualRanges(range, IRHCRangeFull());
}

BOOL IRHCRangeIsVaild(IRHCRange range)
{
    return !IRHCRangeIsInvaild(range);
}

BOOL IRHCRangeIsInvaild(IRHCRange range)
{
    return IRHCEqualRanges(range, IRHCRangeInvaild());
}

BOOL IRHCEqualRanges(IRHCRange range1, IRHCRange range2)
{
    return range1.start == range2.start && range1.end == range2.end;
}

long long IRHCRangeGetLength(IRHCRange range)
{
    if (range.start == IRHCNotFound || range.end == IRHCNotFound) {
        return IRHCNotFound;
    }
    return range.end - range.start + 1;
}

NSString *IRHCStringFromRange(IRHCRange range)
{
    return [NSString stringWithFormat:@"Range : {%lld, %lld}", range.start, range.end];
}

NSString *IRHCRangeGetHeaderString(IRHCRange range)
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"bytes="];
    if (range.start != IRHCNotFound) {
        [string appendFormat:@"%lld", range.start];
    }
    [string appendFormat:@"-"];
    if (range.end != IRHCNotFound) {
        [string appendFormat:@"%lld", range.end];
    }
    return [string copy];
}

NSDictionary *IRHCRangeFillToRequestHeaders(IRHCRange range, NSDictionary *headers)
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:headers];
    [ret setObject:IRHCRangeGetHeaderString(range) forKey:@"Range"];
    return ret;
}

NSDictionary *IRHCRangeFillToRequestHeadersIfNeeded(IRHCRange range, NSDictionary *headers)
{
    if ([headers objectForKey:@"Range"]) {
        return headers;
    }
    return IRHCRangeFillToRequestHeaders(range, headers);
}

NSDictionary *IRHCRangeFillToResponseHeaders(IRHCRange range, NSDictionary *headers, long long totalLength)
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:headers];
    long long currentLength = IRHCRangeGetLength(range);
    [ret setObject:[NSString stringWithFormat:@"%lld", currentLength] forKey:@"Content-Length"];
    [ret setObject:[NSString stringWithFormat:@"bytes %lld-%lld/%lld", range.start, range.end, totalLength] forKey:@"Content-Range"];
    return ret;
}

IRHCRange IRHCMakeRange(long long start, long long end)
{
    IRHCRange range = {start, end};
    return range;
}

IRHCRange IRHCRangeZero(void)
{
    return IRHCMakeRange(0, 0);
}

IRHCRange IRHCRangeFull(void)
{
    return IRHCMakeRange(0, IRHCNotFound);
}

IRHCRange IRHCRangeInvaild()
{
    return IRHCMakeRange(IRHCNotFound, IRHCNotFound);
}

IRHCRange IRHCRangeWithSeparateValue(NSString *value)
{
    IRHCRange range = IRHCRangeInvaild();
    if (value.length > 0) {
        NSArray *components = [value componentsSeparatedByString:@","];
        if (components.count == 1) {
            components = [components.firstObject componentsSeparatedByString:@"-"];
            if (components.count == 2) {
                NSString *startString = [components objectAtIndex:0];
                NSInteger startValue = [startString integerValue];
                NSString *endString = [components objectAtIndex:1];
                NSInteger endValue = [endString integerValue];
                if (startString.length && (startValue >= 0) && endString.length && (endValue >= startValue)) {
                    // The second 500 bytes: "500-999"
                    range.start = startValue;
                    range.end = endValue;
                } else if (startString.length && (startValue >= 0)) {
                    // The bytes after 9500 bytes: "9500-"
                    range.start = startValue;
                    range.end = IRHCNotFound;
                } else if (endString.length && (endValue > 0)) {
                    // The final 500 bytes: "-500"
                    range.start = IRHCNotFound;
                    range.end = endValue;
                }
            }
        }
    }
    return range;
}

IRHCRange IRHCRangeWithRequestHeaderValue(NSString *value)
{
    if ([value hasPrefix:@"bytes="]) {
        NSString *rangeString = [value substringFromIndex:6];
        return IRHCRangeWithSeparateValue(rangeString);
    }
    return IRHCRangeInvaild();
}

IRHCRange IRHCRangeWithResponseHeaderValue(NSString *value, long long *totalLength)
{
    if ([value hasPrefix:@"bytes "]) {
        value = [value stringByReplacingOccurrencesOfString:@"bytes " withString:@""];
        NSRange range = [value rangeOfString:@"/"];
        if (range.location != NSNotFound) {
            NSString *rangeString = [value substringToIndex:range.location];
            NSString *totalLengthString = [value substringFromIndex:range.location + range.length];
            *totalLength = totalLengthString.longLongValue;
            return IRHCRangeWithSeparateValue(rangeString);
        }
    }
    return IRHCRangeInvaild();
}

IRHCRange IRHCRangeWithEnsureLength(IRHCRange range, long long ensureLength)
{
    if (range.end == IRHCNotFound && ensureLength > 0) {
        return IRHCMakeRange(range.start, ensureLength - 1);
    }
    return range;
}

