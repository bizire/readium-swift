//
//  MultipartMessageHeaderField.h
//  IRCocoaHTTPServer
//
//  Created by irons on 2021/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultipartMessageHeaderField : NSObject {
    NSString*                        name;
    NSString*                        value;
    NSMutableDictionary*            params;
}

@property (strong, readonly) NSString*        value;
@property (strong, readonly) NSDictionary*    params;
@property (strong, readonly) NSString*        name;

//- (id) initWithLine:(NSString*) line;
//- (id) initWithName:(NSString*) paramName value:(NSString*) paramValue;

- (id) initWithData:(NSData*) data contentEncoding:(NSStringEncoding) encoding;

@end


NS_ASSUME_NONNULL_END
